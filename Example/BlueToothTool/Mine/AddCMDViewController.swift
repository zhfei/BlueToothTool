//
//  AddCMDViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/11.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool
import UniformTypeIdentifiers

// MARK: - CommandItem Data Model

struct CommandItem: Codable {
    let cmdTitle: String
    let cmd: String  // 十六进制字符串
    let createTime: Date
    
    init(cmdTitle: String, cmd: String, createTime: Date = Date()) {
        self.cmdTitle = cmdTitle
        self.cmd = cmd
        self.createTime = createTime
    }
}

// JSON 导入格式
struct CommandJSONItem: Codable {
    let cmdTitle: String
    let cmd: String
}

class AddCMDViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    private var commands: [CommandItem] = []
    
    private let commandsFileName = "CommandList.plist"
    
    private var commandsFilePath: URL {
        return FileUtils.shared.getDocumentsDirectory().appendingPathComponent(commandsFileName)
    }
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Color.backgroundGray
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.backgroundGray
        return view
    }()
    
    private let inputCardView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "指令标题（例如：获取设备全部信息）"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.backgroundColor = Color.backgroundGray
        return textField
    }()
    
    private let cmdTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = Color.backgroundGray
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("保存指令", for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.backgroundColor = Color.lakeBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let ruleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = Color.grayText
        label.numberOfLines = 0
        label.text = "指令规则：\n• 请输入有效的十六进制字节指令\n• 两个字节之间用空格隔开（例如：08 EE 00 00）\n• 支持手动输入或从粘贴板粘贴十六进制数据"
        return label
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "指令内容（十六进制，例如：08 EE 00 00）\n两个字节之间用空格隔开，支持手动输入或从粘贴板粘贴"
        label.font = .systemFont(ofSize: 14)
        label.textColor = Color.grayText
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadCommands()
        setupTextViewPlaceholder()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "添加调试指令"
        
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 输入卡片
        contentView.addSubview(inputCardView)
        inputCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        inputCardView.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        inputCardView.addSubview(cmdTextView)
        cmdTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(120)
        }
        
        cmdTextView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-12)
        }
        
        inputCardView.addSubview(ruleLabel)
        ruleLabel.snp.makeConstraints { make in
            make.top.equalTo(cmdTextView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        inputCardView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(ruleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // 设置 contentView 底部约束
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(inputCardView.snp.bottom).offset(16)
        }
    }
    
    private func setupTextViewPlaceholder() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewDidChange),
            name: UITextView.textDidChangeNotification,
            object: cmdTextView
        )
    }
    
    @objc private func textViewDidChange() {
        placeholderLabel.isHidden = !cmdTextView.text.isEmpty
    }
    
    private func setupNavigationBar() {
        // 导入JSON按钮
        let importButton = UIBarButtonItem(
            title: "导入JSON",
            style: .plain,
            target: self,
            action: #selector(importJSONButtonTapped)
        )
        
        // 分享按钮
        let shareButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [shareButton, importButton]
    }
    
    // MARK: - File Management
    
    private func loadCommands() {
        guard FileUtils.shared.fileExists(at: commandsFilePath) else {
            commands = []
            return
        }
        
        guard let data = FileUtils.shared.readFile(at: commandsFilePath) else {
            commands = []
            return
        }
        
        do {
            let decoder = PropertyListDecoder()
            commands = try decoder.decode([CommandItem].self, from: data)
        } catch {
            print("❌ 加载指令列表失败: \(error.localizedDescription)")
            commands = []
        }
    }
    
    private func saveCommands() -> Bool {
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let data = try encoder.encode(commands)
            return FileUtils.shared.createFile(at: commandsFilePath, contents: data)
        } catch {
            print("❌ 保存指令列表失败: \(error.localizedDescription)")
            return false
        }
    }
    
    private func appendCommand(_ command: CommandItem) {
        commands.append(command)
        if saveCommands() {
            print("✅ 指令保存成功")
        } else {
            print("❌ 指令保存失败")
        }
    }
    
    // MARK: - Command Processing
    
    /// 解析十六进制字符串为字节数组
    private func parseHexString(_ hexString: String) -> [UInt8]? {
        // 移除空格、0x前缀、换行符等
        let cleaned = hexString
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "0x", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 验证是否为有效的十六进制字符串
        guard cleaned.count % 2 == 0,
              cleaned.allSatisfy({ $0.isHexDigit }) else {
            return nil
        }
        
        // 转换为字节数组
        var bytes: [UInt8] = []
        var index = cleaned.startIndex
        
        while index < cleaned.endIndex {
            let nextIndex = cleaned.index(index, offsetBy: 2)
            let hexByte = String(cleaned[index..<nextIndex])
            if let byte = UInt8(hexByte, radix: 16) {
                bytes.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        
        return bytes
    }
    
    /// 格式化字节数组为十六进制字符串
    private func formatHexString(_ bytes: [UInt8]) -> String {
        return bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    /// 计算checksum（CS前所有字节之和的最低字节）
    private func calculateChecksum(_ bytes: [UInt8]) -> UInt8 {
        let sum = bytes.reduce(0) { $0 + UInt($1) }
        return UInt8(sum & 0xFF)
    }
    
    /// 处理指令：验证和格式化十六进制字符串
    /// 只负责验证输入是否为有效的十六进制字节，并格式化为空格分隔的字符串
    private func processCommand(_ hexString: String) -> String? {
        guard let dataBytes = parseHexString(hexString) else {
            return nil
        }
        
        // 直接格式化字节数组为空格分隔的十六进制字符串
        return formatHexString(dataBytes)
    }
    
    /// 验证十六进制字符串格式
    private func validateHexString(_ hexString: String) -> Bool {
        let cleaned = hexString
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "0x", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !cleaned.isEmpty &&
               cleaned.count % 2 == 0 &&
               cleaned.allSatisfy { $0.isHexDigit }
    }
    
    // MARK: - Actions
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "提示", message: "请输入指令标题")
            return
        }
        
        guard let cmdText = cmdTextView.text, !cmdText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "提示", message: "请输入指令内容")
            return
        }
        
        guard validateHexString(cmdText) else {
            showAlert(title: "错误", message: "指令格式不正确，请输入有效的十六进制字符串")
            return
        }
        
        // 处理指令（格式化为空格分隔的十六进制字符串）
        guard let processedCmd = processCommand(cmdText) else {
            showAlert(title: "错误", message: "指令处理失败，请检查格式")
            return
        }
        
        // 创建指令项
        let command = CommandItem(cmdTitle: title, cmd: processedCmd)
        
        // 保存指令
        appendCommand(command)
        
        // 清空输入框
        titleTextField.text = ""
        cmdTextView.text = ""
        placeholderLabel.isHidden = false
        
        // 显示成功提示
        showAlert(title: "成功", message: "指令已保存：\(title)\n格式化后的指令：\(processedCmd)")
    }
    
    @objc private func importJSONButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        // iPad 支持
        if let popover = documentPicker.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.last
        }
        
        present(documentPicker, animated: true)
    }
    
    @objc private func shareButtonTapped() {
        guard FileUtils.shared.fileExists(at: commandsFilePath) else {
            showAlert(title: "提示", message: "还没有保存任何指令")
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [commandsFilePath],
            applicationActivities: nil
        )
        
        // iPad 支持
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }
        
        present(activityVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIDocumentPickerDelegate

extension AddCMDViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // 开始访问文件
        guard url.startAccessingSecurityScopedResource() else {
            showAlert(title: "错误", message: "无法访问文件")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // 读取JSON文件
        guard let data = FileUtils.shared.readFile(at: url) else {
            showAlert(title: "错误", message: "无法读取文件")
            return
        }
        
        // 解析JSON
        do {
            let jsonItems = try JSONDecoder().decode([CommandJSONItem].self, from: data)
            
            var successCount = 0
            var failCount = 0
            
            for jsonItem in jsonItems {
                // 验证指令格式
                if validateHexString(jsonItem.cmd) {
                    // 处理指令（格式化为空格分隔的十六进制字符串）
                    let processedCmd = processCommand(jsonItem.cmd) ?? jsonItem.cmd
                    let command = CommandItem(cmdTitle: jsonItem.cmdTitle, cmd: processedCmd)
                    appendCommand(command)
                    successCount += 1
                } else {
                    failCount += 1
                }
            }
            
            let message = "导入完成\n成功：\(successCount) 条\n失败：\(failCount) 条"
            showAlert(title: "导入结果", message: message)
            
        } catch {
            showAlert(title: "错误", message: "JSON格式不正确：\(error.localizedDescription)")
        }
    }
}

// MARK: - Character Extension

extension Character {
    var isHexDigit: Bool {
        return ("0"..."9").contains(self) || ("A"..."F").contains(self) || ("a"..."f").contains(self)
    }
}

//
//  CMDMFISenderViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

/*
 指令发送页面
 */

import UIKit
import SnapKit
import BlueToothTool
import ExternalAccessory

class CMDMFISenderViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    var device: MFIDeviceModel?
    var session: EASession?
    var protocolString: String?
    
    /// 待发送的数据队列
    private var pendingSendData: [Data] = []
    
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
    
    private let inputContainerView: UIView = {
        let view = UIView()
        return view
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
    
    private let addLocalCommandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加本地指令", for: .normal)
        button.setTitleColor(Color.lakeBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let resultCardView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let resultTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "返回结果"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Color.primaryText
        return label
    }()
    
    private let resultTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 13, weight: .regular)
        textView.backgroundColor = Color.backgroundGray
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.isEditable = false
        textView.textColor = Color.grayText
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送指令", for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.backgroundColor = Color.lakeBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "指令内容（十六进制，例如：08 EE 00 00）\n两个字节之间用空格隔开"
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
        openSessionStreams()
        setupTextViewPlaceholder()
        setupTapGestureToDismissKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 不在此处关闭流，避免跳转到其他页面时误关闭会话
        // 流的关闭逻辑已移至 deinit 中，确保页面真正销毁时才关闭
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "指令发送"
        
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
        
        inputCardView.addSubview(inputContainerView)
        inputContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 添加本地指令按钮
        inputContainerView.addSubview(addLocalCommandButton)
        addLocalCommandButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
        }
        addLocalCommandButton.addTarget(self, action: #selector(addLocalCommandButtonTapped), for: .touchUpInside)
        
        // 指令输入框
        inputContainerView.addSubview(cmdTextView)
        cmdTextView.snp.makeConstraints { make in
            make.top.equalTo(addLocalCommandButton.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(120)
        }
        
        cmdTextView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-12)
        }
        
        inputCardView.snp.makeConstraints { make in
            make.bottom.equalTo(inputContainerView.snp.bottom).offset(16)
        }
        
        // 结果卡片
        contentView.addSubview(resultCardView)
        resultCardView.snp.makeConstraints { make in
            make.top.equalTo(inputCardView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(200)
        }
        
        resultCardView.addSubview(resultTitleLabel)
        resultTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        resultCardView.addSubview(resultTextView)
        resultTextView.snp.makeConstraints { make in
            make.top.equalTo(resultTitleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        
        // 发送按钮
        contentView.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(resultCardView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        // 可以添加导航栏按钮
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
    
    private func setupTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Session Management
    
    private func openSessionStreams() {
        guard let session = session else { return }
        
        // 打开输入流
        if let inputStream = session.inputStream {
            inputStream.delegate = self
            inputStream.schedule(in: RunLoop.current, forMode: .common)
            inputStream.open()
        }
        
        // 打开输出流
        if let outputStream = session.outputStream {
            outputStream.delegate = self
            outputStream.schedule(in: RunLoop.current, forMode: .common)
            outputStream.open()
        }
        
        LogDebug("session:\(session)")
    }
    
    // MARK: - Actions
    
    @objc private func addLocalCommandButtonTapped() {
        let cmdListVC = CMDListViewController()
        cmdListVC.delegate = self
        PageManager.pushViewController(cmdListVC, animated: true)
    }
    
    @objc private func sendButtonTapped() {
        guard let cmdText = cmdTextView.text, !cmdText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "提示", message: "请输入指令内容")
            return
        }
        
        guard validateHexString(cmdText) else {
            showAlert(title: "错误", message: "指令格式不正确，请输入有效的十六进制字符串")
            return
        }
        
        // 解析并发送指令
        guard let data = parseHexStringToData(cmdText) else {
            showAlert(title: "错误", message: "指令解析失败")
            return
        }
        
        sendData(data)
    }
    
    // MARK: - Data Validation & Parsing
    
    private func validateHexString(_ hexString: String) -> Bool {
        let cleaned = hexString
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "0x", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !cleaned.isEmpty &&
               cleaned.count % 2 == 0 &&
               cleaned.allSatisfy { $0.isHexDigitCMD }
    }
    
    private func parseHexStringToData(_ hexString: String) -> Data? {
        let cleaned = hexString
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "0x", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard cleaned.count % 2 == 0,
              cleaned.allSatisfy({ $0.isHexDigitCMD }) else {
            return nil
        }
        
        var data = Data()
        var index = cleaned.startIndex
        
        while index < cleaned.endIndex {
            let nextIndex = cleaned.index(index, offsetBy: 2)
            let hexByte = String(cleaned[index..<nextIndex])
            if let byte = UInt8(hexByte, radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        
        return data
    }
    
    // MARK: - Send & Receive Data
    
    private func sendData(_ data: Data) {
        guard let outputStream = session?.outputStream else {
            showAlert(title: "错误", message: "输出流未打开")
            return
        }
        
        // 检查流的状态，而不是 hasSpaceAvailable（hasSpaceAvailable 是事件驱动的）
        guard outputStream.streamStatus == .open else {
            showAlert(title: "提示", message: "输出流尚未打开，状态: \(streamStatusString(outputStream.streamStatus.rawValue))")
            outputStream.open()
            session?.inputStream?.open()
            return
        }
        
        let bytes = [UInt8](data)
        let bytesWritten = outputStream.write(bytes, maxLength: bytes.count)
        
        if bytesWritten > 0 {
            // 显示已发送的指令部分
            let sentData = data.subdata(in: 0..<bytesWritten)
            let hexString = sentData.map { String(format: "%02X", $0) }.joined(separator: " ")
            appendToResult(text: "发送: \(hexString)\n", isSend: true)
            
            // 如果数据没有完全发送，将剩余数据放入队列
            if bytesWritten < bytes.count {
                let remainingData = data.subdata(in: bytesWritten..<data.count)
                pendingSendData.append(remainingData)
                appendToResult(text: "部分数据已加入发送队列\n", isSend: true)
            }
        } else if bytesWritten == 0 {
            // 缓冲区暂时满，将数据放入队列等待发送
            pendingSendData.append(data)
            appendToResult(text: "数据已加入发送队列（等待发送）\n", isSend: true)
        } else if bytesWritten < 0 {
            // 发送错误
            showAlert(title: "错误", message: "发送失败: \(outputStream.streamError?.localizedDescription ?? "未知错误")")
        }
    }
    
    private func streamStatusString(_ status: UInt) -> String {
        guard let streamStatus = Stream.Status(rawValue: status) else {
            return "未知"
        }
        
        switch streamStatus {
        case .notOpen:
            return "未打开"
        case .opening:
            return "打开中"
        case .open:
            return "已打开"
        case .reading:
            return "读取中"
        case .writing:
            return "写入中"
        case .atEnd:
            return "已结束"
        case .closed:
            return "已关闭"
        case .error:
            return "错误"
        @unknown default:
            return "未知"
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
        appendToResult(text: "接收: \(hexString)\n", isSend: false)
    }
    
    /// 处理待发送队列
    private func processPendingSendQueue() {
        guard let outputStream = session?.outputStream,
              outputStream.streamStatus == .open,
              !pendingSendData.isEmpty else {
            return
        }
        
        var remainingQueue: [Data] = []
        
        for data in pendingSendData {
            let bytes = [UInt8](data)
            let bytesWritten = outputStream.write(bytes, maxLength: bytes.count)
            
            if bytesWritten > 0 {
                // 部分或全部发送成功
                let sentData = data.subdata(in: 0..<bytesWritten)
                let hexString = sentData.map { String(format: "%02X", $0) }.joined(separator: " ")
                appendToResult(text: "队列发送: \(hexString)\n", isSend: true)
                
                if bytesWritten < data.count {
                    // 部分发送，保留剩余数据
                    let remainingData = data.subdata(in: bytesWritten..<data.count)
                    remainingQueue.append(remainingData)
                }
                // 完全发送成功，不需要保留
            } else if bytesWritten == 0 {
                // 缓冲区满，保留数据
                remainingQueue.append(data)
            } else {
                // 发送错误，移除数据（避免无限重试）
                appendToResult(text: "队列发送失败: \(outputStream.streamError?.localizedDescription ?? "未知错误")\n", isSend: true)
            }
        }
        
        pendingSendData = remainingQueue
    }
    
    private func appendToResult(text: String, isSend: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let color = isSend ? Color.lakeBlue : Color.green
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .font: UIFont.systemFont(ofSize: 13, weight: .regular)
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            
            let existingAttributedText = self.resultTextView.attributedText ?? NSAttributedString()
            let mutableAttributedString = NSMutableAttributedString(attributedString: existingAttributedText)
            mutableAttributedString.append(attributedString)
            
            self.resultTextView.attributedText = mutableAttributedString
            
            // 滚动到底部
            let textLength = mutableAttributedString.length
            if textLength > 0 {
                let bottom = NSRange(location: textLength - 1, length: 1)
                self.resultTextView.scrollRangeToVisible(bottom)
            }
        }
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
        // 页面销毁时关闭会话流，确保资源正确释放
        if let inputStream = session?.inputStream {
            inputStream.remove(from: RunLoop.current, forMode: .common)
            inputStream.close()
        }
        if let outputStream = session?.outputStream {
            outputStream.remove(from: RunLoop.current, forMode: .common)
            outputStream.close()
        }
    }
}

// MARK: - StreamDelegate

extension CMDMFISenderViewController: StreamDelegate {
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            print("流已打开")
        case .hasBytesAvailable:
            print("有数据可读")
            if let inputStream = aStream as? InputStream {
                handleInputStream(inputStream)
            }
        case .hasSpaceAvailable:
            print("有空间可写")
            // 发送队列中的数据
            processPendingSendQueue()
        case .errorOccurred:
            print("流错误: \(aStream.streamError?.localizedDescription ?? "未知错误")")
        case .endEncountered:
            print("流已结束")
        default:
            break
        }
    }
    
    private func handleInputStream(_ inputStream: InputStream) {
        var buffer = [UInt8](repeating: 0, count: 1024)
        let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
        
        if bytesRead > 0 {
            let data = Data(buffer.prefix(bytesRead))
            handleReceivedData(data)
        }
    }
}

// MARK: - CMDListViewControllerDelegate

extension CMDMFISenderViewController: CMDListViewControllerDelegate {
    
    func didSelectCommand(_ command: CommandItem) {
        // 将选择的指令填充到输入框
        cmdTextView.text = command.cmd
        placeholderLabel.isHidden = !cmdTextView.text.isEmpty
    }
}

// MARK: - Character Extension

extension Character {
    var isHexDigitCMD: Bool {
        return ("0"..."9").contains(self) || ("A"..."F").contains(self) || ("a"..."f").contains(self)
    }
}

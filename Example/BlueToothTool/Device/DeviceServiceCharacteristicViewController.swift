//
//  DeviceServiceCharacteristicViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/10.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import CoreBluetooth
import BlueToothTool

class DeviceServiceCharacteristicViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    var peripheral: CBPeripheral?
    var service: CBService?
    var characteristic: CBCharacteristic?
    
    private var logMessages: [String] = []
    private var isNotifyEnabled = false
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        return view
    }()
    
    private let leftContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        return view
    }()
    
    private let rightScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Color.backgroundGray
        return scrollView
    }()
    
    private let rightContentView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.backgroundGray
        return view
    }()
    
    private let logTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = Color.backgroundGray
        textView.font = .systemFont(ofSize: 12)
        textView.textColor = Color.primaryText
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    // Read 类型 UI
    private let readButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read", for: .normal)
        button.backgroundColor = Color.lakeBlue
        button.setTitleColor(Color.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Write 类型 UI
    private let writeTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = Color.backgroundGray
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = Color.primaryText
        textView.layer.borderColor = Color.seperatorLine.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.backgroundColor = Color.green
        button.setTitleColor(Color.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Notify 类型 UI
    private let notifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("接收通知", for: .normal)
        button.backgroundColor = Color.orange
        button.setTitleColor(Color.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Broadcast 类型 UI
    private let broadcastButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("接收广播", for: .normal)
        button.backgroundColor = Color.purple
        button.setTitleColor(Color.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBLEManagerCallbacks()
        setupCharacteristicUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 取消通知
        if let characteristic = characteristic, isNotifyEnabled {
            peripheral?.setNotifyValue(false, for: characteristic)
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "特征详情"
        
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        view.backgroundColor = Color.backgroundGray
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        containerView.addSubview(leftContainerView)
        leftContainerView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(120)
        }
        
        containerView.addSubview(rightScrollView)
        rightScrollView.snp.makeConstraints { make in
            make.left.equalTo(leftContainerView.snp.right).offset(8)
            make.right.top.bottom.equalToSuperview()
        }
        
        rightScrollView.addSubview(rightContentView)
        rightContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        rightContentView.addSubview(logTextView)
        logTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(400)
        }
    }
    
    private func setupBLEManagerCallbacks() {
        // 确保 peripheral 的 delegate 设置正确
        peripheral?.delegate = BLEManager.shared
        
        // 特征值更新回调
        BLEManager.shared.onCharacteristicValueUpdated = { [weak self] updatedCharacteristic, data in
            guard let self = self,
                  let characteristic = self.characteristic,
                  updatedCharacteristic.uuid == characteristic.uuid else {
                return
            }
            
            let hexString = data?.map { String(format: "%02X", $0) }.joined(separator: " ") ?? "无数据"
            let timestamp = DateFormatter.timeFormatter.string(from: Date())
            self.appendLog("\(timestamp) 收到数据: \(hexString)")
        }
        
        // 特征写入完成回调
        BLEManager.shared.onCharacteristicWriteCompleted = { [weak self] updatedCharacteristic, error in
            guard let self = self,
                  let characteristic = self.characteristic,
                  updatedCharacteristic.uuid == characteristic.uuid else {
                return
            }
            
            let timestamp = DateFormatter.timeFormatter.string(from: Date())
            if let error = error {
                self.appendLog("\(timestamp) 写入失败: \(error.localizedDescription)")
            } else {
                self.appendLog("\(timestamp) 写入成功")
            }
        }
    }
    
    private func setupCharacteristicUI() {
        guard let characteristic = characteristic else { return }
        
        // 清空左侧容器
        leftContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        var lastView: UIView?
        let spacing: CGFloat = 12
        
        // 根据特征属性显示不同的UI（不是互斥关系，所有匹配的类型都要显示）
        if characteristic.properties.contains(.read) {
            lastView = setupReadUI(lastView: lastView, spacing: spacing)
        }
        
        if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
            lastView = setupWriteUI(lastView: lastView, spacing: spacing)
        }
        
        if characteristic.properties.contains(.notify) {
            lastView = setupNotifyUI(lastView: lastView, spacing: spacing)
        }
        
        if characteristic.properties.contains(.broadcast) {
            lastView = setupBroadcastUI(lastView: lastView, spacing: spacing)
        }
    }
    
    @discardableResult
    private func setupReadUI(lastView: UIView?, spacing: CGFloat) -> UIView {
        leftContainerView.addSubview(readButton)
        
        if let lastView = lastView {
            readButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(lastView.snp.bottom).offset(spacing)
                make.height.equalTo(44)
            }
        } else {
            readButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(16)
                make.height.equalTo(44)
            }
        }
        
        readButton.addTarget(self, action: #selector(readButtonTapped), for: .touchUpInside)
        return readButton
    }
    
    @discardableResult
    private func setupWriteUI(lastView: UIView?, spacing: CGFloat) -> UIView {
        leftContainerView.addSubview(writeTextView)
        
        if let lastView = lastView {
            writeTextView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(lastView.snp.bottom).offset(spacing)
                make.height.equalTo(100)
            }
        } else {
            writeTextView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(16)
                make.height.equalTo(100)
            }
        }
        
        leftContainerView.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(writeTextView.snp.bottom).offset(12)
            make.height.equalTo(44)
        }
        
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return sendButton
    }
    
    @discardableResult
    private func setupNotifyUI(lastView: UIView?, spacing: CGFloat) -> UIView {
        leftContainerView.addSubview(notifyButton)
        
        if let lastView = lastView {
            notifyButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(lastView.snp.bottom).offset(spacing)
                make.height.equalTo(44)
            }
        } else {
            notifyButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(16)
                make.height.equalTo(44)
            }
        }
        
        notifyButton.addTarget(self, action: #selector(notifyButtonTapped), for: .touchUpInside)
        return notifyButton
    }
    
    @discardableResult
    private func setupBroadcastUI(lastView: UIView?, spacing: CGFloat) -> UIView {
        leftContainerView.addSubview(broadcastButton)
        
        if let lastView = lastView {
            broadcastButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(lastView.snp.bottom).offset(spacing)
                make.height.equalTo(44)
            }
        } else {
            broadcastButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(16)
                make.height.equalTo(44)
            }
        }
        
        broadcastButton.addTarget(self, action: #selector(broadcastButtonTapped), for: .touchUpInside)
        return broadcastButton
    }
    
    // MARK: - Actions
    
    @objc private func readButtonTapped() {
        guard let characteristic = characteristic,
              let peripheral = peripheral else { return }
        
        appendLog("\(DateFormatter.timeFormatter.string(from: Date())) 发送读取请求...")
        peripheral.readValue(for: characteristic)
    }
    
    @objc private func sendButtonTapped() {
        guard let characteristic = characteristic,
              let peripheral = peripheral,
              let text = writeTextView.text,
              !text.isEmpty else {
            appendLog("\(DateFormatter.timeFormatter.string(from: Date())) 错误: 输入内容为空")
            return
        }
        
        // 将文本转换为 Data（这里简单处理，实际可能需要根据协议转换）
        guard let data = text.data(using: .utf8) else {
            appendLog("\(DateFormatter.timeFormatter.string(from: Date())) 错误: 无法转换数据")
            return
        }
        
        let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
        appendLog("\(DateFormatter.timeFormatter.string(from: Date())) 发送: \(hexString)")
        
        // 根据特征属性选择写入方式
        if characteristic.properties.contains(.write) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        } else if characteristic.properties.contains(.writeWithoutResponse) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    @objc private func notifyButtonTapped() {
        guard let characteristic = characteristic,
              let peripheral = peripheral else { return }
        
        isNotifyEnabled.toggle()
        peripheral.setNotifyValue(isNotifyEnabled, for: characteristic)
        
        if isNotifyEnabled {
            notifyButton.setTitle("停止通知", for: .normal)
            notifyButton.backgroundColor = Color.red
            appendLog("\(DateFormatter.timeFormatter.string(from: Date())) 已启用通知")
        } else {
            notifyButton.setTitle("接收通知", for: .normal)
            notifyButton.backgroundColor = Color.orange
            appendLog("\(DateFormatter.timeFormatter.string(from: Date())) 已停止通知")
        }
    }
    
    @objc private func broadcastButtonTapped() {
        guard let characteristic = characteristic,
              let peripheral = peripheral else { return }
        
        isNotifyEnabled.toggle()
        peripheral.setNotifyValue(isNotifyEnabled, for: characteristic)
        
        if isNotifyEnabled {
            broadcastButton.setTitle("停止广播", for: .normal)
            broadcastButton.backgroundColor = Color.red
            appendLog("\(DateFormatter.timeFormatter.string(from: Date())) 已启用广播接收")
        } else {
            broadcastButton.setTitle("接收广播", for: .normal)
            broadcastButton.backgroundColor = Color.purple
            appendLog("\(DateFormatter.timeFormatter.string(from: Date())) 已停止广播接收")
        }
    }
    
    // MARK: - Helper Methods
    
    private func appendLog(_ message: String) {
        logMessages.append(message)
        logTextView.text = logMessages.joined(separator: "\n")
        
        // 自动滚动到底部
        if logTextView.text.count > 0 {
            let range = NSRange(location: logTextView.text.count - 1, length: 1)
            logTextView.scrollRangeToVisible(range)
        }
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

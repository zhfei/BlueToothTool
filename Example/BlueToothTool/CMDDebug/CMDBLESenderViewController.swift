//
//  CMDBLESenderViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool
import CoreBluetooth

class CMDBLESenderViewController: CMDMFISenderViewController {
    
    // MARK: - Properties
    
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    var bleDevice: BLEDeviceModel?
    
    private var isNotifyEnabled = false
    
    // MARK: - UI Components
    
    private let buttonsContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    private let readButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("读取", for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.backgroundColor = Color.green
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let notifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("订阅通知", for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.backgroundColor = Color.orange
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 BLE 回调
        setupBLEManagerCallbacks()
        
        // 调整 UI 布局，添加操作按钮
        adjustUIForBLE()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 取消通知订阅
        if isNotifyEnabled, let characteristic = characteristic, let peripheral = peripheral {
            peripheral.setNotifyValue(false, for: characteristic)
        }
    }
    
    deinit {
        // 取消通知订阅
        if isNotifyEnabled, let characteristic = characteristic, let peripheral = peripheral {
            peripheral.setNotifyValue(false, for: characteristic)
        }
    }
    
    // MARK: - Setup
    
    private func adjustUIForBLE() {
        guard let characteristic = characteristic else { return }
        
        // 移除 sendButton 的约束和从父视图移除
        sendButton.snp.removeConstraints()
        sendButton.removeFromSuperview()
        
        // 设置按钮容器
        contentView.addSubview(buttonsContainerView)
        buttonsContainerView.snp.makeConstraints { make in
            make.top.equalTo(resultCardView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // 根据特征属性添加按钮
        if characteristic.properties.contains(.read) {
            buttonsContainerView.addArrangedSubview(readButton)
            readButton.addTarget(self, action: #selector(readButtonTapped), for: .touchUpInside)
        }
        
        // 发送按钮（如果支持写入）
        if characteristic.properties.contains(.write) ||
           characteristic.properties.contains(.writeWithoutResponse) {
            buttonsContainerView.addArrangedSubview(sendButton)
            // 确保 sendButton 的 target-action 已设置（父类已在 setupUI 中设置）
        }
        
        // 订阅通知按钮（如果支持通知或指示）
        if characteristic.properties.contains(.notify) ||
           characteristic.properties.contains(.indicate) {
            buttonsContainerView.addArrangedSubview(notifyButton)
            notifyButton.addTarget(self, action: #selector(notifyButtonTapped), for: .touchUpInside)
        }
    }
    
    // MARK: - BLE Manager Callbacks
    
    private func setupBLEManagerCallbacks() {
        // 特征值更新回调（读取和通知）
        BLEManager.shared.onCharacteristicValueUpdated = { [weak self] characteristic, data in
            guard let self = self,
                  self.characteristic?.uuid == characteristic.uuid else {
                return
            }
            
            if let data = data {
                let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
                self.appendToResult(text: "接收: \(hexString)\n", isSend: false)
            }
        }
        
        // 特征写入完成回调
        BLEManager.shared.onCharacteristicWriteCompleted = { [weak self] characteristic, error in
            guard let self = self,
                  self.characteristic?.uuid == characteristic.uuid else {
                return
            }
            
            if let error = error {
                self.appendToResult(text: "写入失败: \(error.localizedDescription)\n", isSend: true)
                self.showAlert(title: "错误", message: "写入失败: \(error.localizedDescription)")
            } else {
                self.appendToResult(text: "写入成功\n", isSend: true)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func readButtonTapped() {
        guard let characteristic = characteristic,
              let peripheral = peripheral else {
            showAlert(title: "错误", message: "特征或外设不存在")
            return
        }
        
        if characteristic.properties.contains(.read) {
            appendToResult(text: "读取特征值...\n", isSend: true)
            peripheral.readValue(for: characteristic)
        } else {
            showAlert(title: "错误", message: "该特征不支持读取")
        }
    }
    
    override func sendButtonTapped() {
        guard let characteristic = characteristic,
              let peripheral = peripheral else {
            showAlert(title: "错误", message: "特征或外设不存在")
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
        
        // 解析并发送指令
        guard let data = parseHexStringToData(cmdText) else {
            showAlert(title: "错误", message: "指令解析失败")
            return
        }
        
        // 写入特征
        let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
        appendToResult(text: "发送: \(hexString)\n", isSend: true)
        
        // 根据特征属性选择写入方式
        if characteristic.properties.contains(.write) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        } else if characteristic.properties.contains(.writeWithoutResponse) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            // 对于 withoutResponse，立即显示成功（因为没有回调）
            appendToResult(text: "写入成功（无响应）\n", isSend: true)
        } else {
            showAlert(title: "错误", message: "该特征不支持写入")
        }
    }
    
    @objc private func notifyButtonTapped() {
        guard let characteristic = characteristic,
              let peripheral = peripheral else {
            showAlert(title: "错误", message: "特征或外设不存在")
            return
        }
        
        isNotifyEnabled.toggle()
        peripheral.setNotifyValue(isNotifyEnabled, for: characteristic)
        
        if isNotifyEnabled {
            notifyButton.setTitle("停止通知", for: .normal)
            notifyButton.backgroundColor = Color.red
            appendToResult(text: "已启用通知\n", isSend: false)
        } else {
            notifyButton.setTitle("订阅通知", for: .normal)
            notifyButton.backgroundColor = Color.orange
            appendToResult(text: "已停止通知\n", isSend: false)
        }
    }
}

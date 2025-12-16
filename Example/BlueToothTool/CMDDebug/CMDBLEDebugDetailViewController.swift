//
//  CMDBLEDebugDetailViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool
import CoreBluetooth

class CMDBLEDebugDetailViewController: DeviceDetailViewController {
    
    // MARK: - Properties
    
    private var allCharacteristics: [CBCharacteristic] = [] // 存储所有支持写入的特征
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 移除父类设置的连接按钮
        navigationItem.rightBarButtonItem = nil
        
        // 设置指令发送按钮
        setupCommandSenderButton()
        
        // 设置 BLE 回调
        setupBLEManagerCallbacks()
    }
    
    // MARK: - Setup Command Sender Button
    
    private func setupCommandSenderButton() {
        // 只对 BLE 设备显示按钮
        guard let device = device,
              device.peripheral != nil else {
            return
        }
        
        let sendButton = UIBarButtonItem(
            title: "发送指令",
            style: .plain,
            target: self,
            action: #selector(commandSenderButtonTapped)
        )
        navigationItem.rightBarButtonItem = sendButton
    }
    
    // MARK: - Actions
    
    @objc private func commandSenderButtonTapped() {
        guard let device = device else {
            showAlert(title: "提示", message: "设备不存在")
            return
        }
        
        guard let peripheral = device.peripheral else {
            showAlert(title: "提示", message: "设备外设不存在")
            return
        }
        
        // 检查是否已连接
        if peripheral.state == .connected {
            // 如果已连接，直接发现服务
            discoverServices(for: peripheral)
        } else {
            // 如果未连接，先连接设备
            showActivity()
            BLEManager.shared.centralManager.connect(peripheral, options: nil)
        }
    }
    
    // MARK: - BLE Manager Callbacks
    
    private func setupBLEManagerCallbacks() {
        // 设备连接成功回调
        BLEManager.shared.onDeviceConnected = { [weak self] peripheral in
            guard let self = self,
                  self.device?.peripheral?.identifier == peripheral.identifier else {
                return
            }
            
            self.hideActivity()
            print("设备连接成功，开始发现服务...")
            // 发现服务
            self.discoverServices(for: peripheral)
        }
        
        // 服务发现完成回调
        BLEManager.shared.onServicesDiscovered = { [weak self] peripheral, services in
            guard let self = self,
                  self.device?.peripheral?.identifier == peripheral.identifier else {
                return
            }
            
            print("服务发现完成，共发现 \(services.count) 个服务，开始发现特征...")
        }
        
        // 特征发现完成回调
        BLEManager.shared.onCharacteristicsDiscovered = { [weak self] service, characteristics in
            guard let self = self else { return }
            
            // 收集所有支持写入的特征
            for characteristic in characteristics {
                if characteristic.properties.contains(.write) ||
                   characteristic.properties.contains(.writeWithoutResponse) {
                    // 避免重复添加（通过 UUID 和 service UUID 的组合判断）
                    let isDuplicate = self.allCharacteristics.contains { existing in
                        existing.uuid == characteristic.uuid
                    }
                    if !isDuplicate {
                        self.allCharacteristics.append(characteristic)
                    }
                }
            }
            
            // 检查是否所有服务的特征都已发现
            // 如果当前服务的特征已全部发现，尝试显示特征选择列表
            if let peripheral = self.device?.peripheral,
               let services = peripheral.services {
                var allServicesHaveCharacteristics = true
                for svc in services {
                    if svc.characteristics == nil || svc.characteristics?.isEmpty == true {
                        allServicesHaveCharacteristics = false
                        break
                    }
                }
                
                // 如果所有服务的特征都已发现，显示选择列表
                if allServicesHaveCharacteristics {
                    DispatchQueue.main.async {
                        self.showCharacteristicSelection()
                    }
                }
            }
        }
    }
    
    // MARK: - Service Discovery
    
    private func discoverServices(for peripheral: CBPeripheral) {
        // 清空之前的特征列表
        allCharacteristics.removeAll()
        
        peripheral.delegate = BLEManager.shared
        peripheral.discoverServices(nil)
    }
    
    // MARK: - Characteristic Selection
    
    private func showCharacteristicSelection() {
        // 如果没有找到支持写入的特征，提示用户
        if allCharacteristics.isEmpty {
            showAlert(title: "提示", message: "未找到支持写入的特征")
            return
        }
        
        // 显示特征选择弹框
        let alert = UIAlertController(
            title: "选择特征",
            message: "请选择要发送指令的特征",
            preferredStyle: .actionSheet
        )
        
        for characteristic in allCharacteristics {
            let properties = getCharacteristicPropertiesString(characteristic)
            let title = "\(characteristic.uuid.uuidString)\n\(properties)"
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.navigateToSender(characteristic: characteristic)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad 支持
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func getCharacteristicPropertiesString(_ characteristic: CBCharacteristic) -> String {
        var properties: [String] = []
        if characteristic.properties.contains(.read) { properties.append("Read") }
        if characteristic.properties.contains(.write) { properties.append("Write") }
        if characteristic.properties.contains(.writeWithoutResponse) { properties.append("WriteWithoutResponse") }
        if characteristic.properties.contains(.notify) { properties.append("Notify") }
        if characteristic.properties.contains(.indicate) { properties.append("Indicate") }
        if characteristic.properties.contains(.broadcast) { properties.append("Broadcast") }
        return properties.joined(separator: ", ")
    }
    
    // MARK: - Navigation
    
    private func navigateToSender(characteristic: CBCharacteristic) {
        guard let peripheral = device?.peripheral else {
            showAlert(title: "错误", message: "设备外设不存在")
            return
        }
        
        // 跳转到指令发送页面
        let senderVC = CMDBLESenderViewController()
        senderVC.hidesBottomBarWhenPushed = true
        senderVC.peripheral = peripheral
        senderVC.characteristic = characteristic
        senderVC.bleDevice = device
        PageManager.pushViewController(senderVC, animated: true)
    }
    
    // MARK: - Helper
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

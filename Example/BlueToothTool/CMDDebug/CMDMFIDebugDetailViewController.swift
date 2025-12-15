//
//  CMDDebugDetailViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/11.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool
import ExternalAccessory

class CMDMFIDebugDetailViewController: DeviceDetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 移除父类设置的连接按钮
        navigationItem.rightBarButtonItem = nil
        
        // 设置指令发送按钮
        setupCommandSenderButton()
    }
    
    // MARK: - Setup Command Sender Button
    
    private func setupCommandSenderButton() {
        // 只对 MFI 设备显示按钮
        guard let mfiDevice = mfiDevice,
              mfiDevice.isConnected,
              !mfiDevice.protocolStrings.isEmpty else {
            return
        }
        
        let sendButton = UIBarButtonItem(
            title: "指令发送",
            style: .plain,
            target: self,
            action: #selector(commandSenderButtonTapped)
        )
        navigationItem.rightBarButtonItem = sendButton
    }
    
    @objc private func commandSenderButtonTapped() {
        guard let mfiDevice = mfiDevice else {
            showAlert(title: "提示", message: "设备不存在")
            return
        }
        
        // 检查设备是否已连接且有可用协议
        guard mfiDevice.isConnected else {
            showAlert(title: "提示", message: "设备未连接")
            return
        }
        
        guard !mfiDevice.protocolStrings.isEmpty else {
            showAlert(title: "提示", message: "设备没有可用协议")
            return
        }
        
        // 显示协议选择弹框
        let alert = UIAlertController(
            title: "选择协议",
            message: "请选择要建立连接的协议",
            preferredStyle: .actionSheet
        )
        
        for protocolString in mfiDevice.protocolStrings {
            alert.addAction(UIAlertAction(title: protocolString, style: .default) { [weak self] _ in
                self?.createMFISessionAndNavigate(protocolString: protocolString)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad 支持
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Create MFI Session
    
    private func createMFISessionAndNavigate(protocolString: String) {
        guard let mfiDevice = mfiDevice else {
            showAlert(title: "错误", message: "设备不存在")
            return
        }
        
        guard let accessory = mfiDevice.accessory else {
            showAlert(title: "错误", message: "设备外设不存在")
            return
        }
        
        guard accessory.isConnected else {
            showAlert(title: "错误", message: "设备未连接")
            return
        }
        
        guard accessory.protocolStrings.contains(protocolString) else {
            showAlert(title: "错误", message: "设备不支持该协议")
            return
        }
        
        // 创建会话
        let session = EASession(accessory: accessory, forProtocol: protocolString)
        
        guard session != nil else {
            showAlert(title: "错误", message: "创建会话失败")
            return
        }
        
        // 跳转到指令发送页面
        let senderVC = CMDMFISenderViewController()
        senderVC.hidesBottomBarWhenPushed = true
        senderVC.device = mfiDevice
        senderVC.session = session
        senderVC.protocolString = protocolString
        PageManager.pushViewController(senderVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

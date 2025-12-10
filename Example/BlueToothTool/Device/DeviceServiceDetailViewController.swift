//
//  DeviceServiceDetailViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/9.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import CoreBluetooth
import BlueToothTool

class DeviceServiceDetailViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    var peripheral: CBPeripheral?
    var services: [CBService] = []
    
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
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBLEManagerCallbacks()
        updateServicesInfo()
        setupDisconnectButton()
    }
    
    // MARK: - Setup Disconnect Button
    
    private func setupDisconnectButton() {
        let disconnectButton = UIBarButtonItem(
            title: "断开连接",
            style: .plain,
            target: self,
            action: #selector(disconnectButtonTapped)
        )
        navigationItem.rightBarButtonItem = disconnectButton
    }
    
    @objc private func disconnectButtonTapped() {
        guard let peripheral = peripheral else { return }
        BLEManager.shared.centralManager.cancelPeripheralConnection(peripheral)
        
        // 返回到设备详情页
        PageManager.popToViewController(ofType: DeviceDetailViewController.self, animated: true)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "设备服务"
        
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
    }
    
    private func setupBLEManagerCallbacks() {
        // 特征发现完成回调
        BLEManager.shared.onCharacteristicsDiscovered = { [weak self] service, characteristics in
            guard let self = self else { return }
            
            // 更新对应服务的特征信息
            DispatchQueue.main.async {
                self.updateServicesInfo()
            }
        }
    }
    
    private func updateServicesInfo() {
        // 清空之前的内容
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var lastView: UIView?
        
        // 遍历所有服务
        for (serviceIndex, service) in services.enumerated() {
            // 服务标题
            let serviceSection = createSectionView(title: "服务 \(serviceIndex + 1): \(service.uuid.uuidString)")
            contentView.addSubview(serviceSection)
            if let last = lastView {
                serviceSection.snp.makeConstraints { make in
                    make.top.equalTo(last.snp.bottom).offset(16)
                    make.left.right.equalToSuperview()
                }
            } else {
                serviceSection.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(16)
                    make.left.right.equalToSuperview()
                }
            }
            lastView = serviceSection
            
            // 服务 UUID
            let serviceUUIDItem = createInfoItem(title: "服务 UUID", value: service.uuid.uuidString)
            contentView.addSubview(serviceUUIDItem)
            serviceUUIDItem.snp.makeConstraints { make in
                make.top.equalTo(serviceSection.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
            }
            lastView = serviceUUIDItem
            
            // 服务是否为主服务
            let isPrimaryItem = createInfoItem(title: "是否为主服务", value: service.isPrimary ? "是" : "否")
            contentView.addSubview(isPrimaryItem)
            isPrimaryItem.snp.makeConstraints { make in
                make.top.equalTo(lastView!.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
            }
            lastView = isPrimaryItem
            
            // 特征信息
            if let characteristics = service.characteristics, !characteristics.isEmpty {
                let characteristicsSection = createSectionView(title: "特征信息 (共 \(characteristics.count) 个)")
                contentView.addSubview(characteristicsSection)
                characteristicsSection.snp.makeConstraints { make in
                    make.top.equalTo(lastView!.snp.bottom).offset(16)
                    make.left.right.equalToSuperview()
                }
                lastView = characteristicsSection
                
                // 遍历所有特征
                for (charIndex, characteristic) in characteristics.enumerated() {
                    let charItem = createCharacteristicItem(
                        title: "特征 \(charIndex + 1)",
                        characteristic: characteristic
                    )
                    
                    // 添加点击手势
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(characteristicItemTapped(_:)))
                    charItem.addGestureRecognizer(tapGesture)
                    charItem.isUserInteractionEnabled = true
                    charItem.tag = serviceIndex * 1000 + charIndex // 使用组合 tag
                    
                    contentView.addSubview(charItem)
                    charItem.snp.makeConstraints { make in
                        make.top.equalTo(lastView!.snp.bottom).offset(8)
                        make.left.right.equalToSuperview()
                    }
                    lastView = charItem
                }
            } else {
                // 没有特征信息
                let noCharacteristicsItem = createInfoItem(title: "特征信息", value: "暂无特征数据")
                contentView.addSubview(noCharacteristicsItem)
                noCharacteristicsItem.snp.makeConstraints { make in
                    make.top.equalTo(lastView!.snp.bottom).offset(8)
                    make.left.right.equalToSuperview()
                }
                lastView = noCharacteristicsItem
            }
        }
        
        // 设置 contentView 的底部约束
        if let lastView = lastView {
            lastView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-16)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createSectionView(title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = Color.white
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = Color.primaryText
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        return containerView
    }
    
    private func createInfoItem(title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = Color.white
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = Color.grayText
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = Color.primaryText
        valueLabel.numberOfLines = 0
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }
        
        containerView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        // 添加分隔线
        let separator = UIView()
        separator.backgroundColor = Color.seperatorLine
        containerView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        return containerView
    }
    
    private func createCharacteristicItem(title: String, characteristic: CBCharacteristic) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = Color.white
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = Color.grayText
        
        // UUID
        let uuidLabel = UILabel()
        uuidLabel.text = "UUID: \(characteristic.uuid.uuidString)"
        uuidLabel.font = .systemFont(ofSize: 12, weight: .regular)
        uuidLabel.textColor = Color.primaryText
        uuidLabel.numberOfLines = 0
        
        // 属性
        var properties: [String] = []
        if characteristic.properties.contains(.read) { properties.append("Read") }
        if characteristic.properties.contains(.write) { properties.append("Write") }
        if characteristic.properties.contains(.writeWithoutResponse) { properties.append("WriteWithoutResponse") }
        if characteristic.properties.contains(.notify) { properties.append("Notify") }
        if characteristic.properties.contains(.indicate) { properties.append("Indicate") }
        if characteristic.properties.contains(.broadcast) { properties.append("Broadcast") }
        
        let propertiesLabel = UILabel()
        propertiesLabel.text = "属性: \(properties.joined(separator: ", "))"
        propertiesLabel.font = .systemFont(ofSize: 12, weight: .regular)
        propertiesLabel.textColor = Color.primaryText
        propertiesLabel.numberOfLines = 0
        
        // 特征值
        let valueLabel = UILabel()
        if let data = characteristic.value {
            let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            valueLabel.text = "值: \(hexString)"
        } else {
            valueLabel.text = "值: 暂无数据"
        }
        valueLabel.font = .systemFont(ofSize: 12, weight: .regular)
        valueLabel.textColor = Color.lakeBlue
        valueLabel.numberOfLines = 0
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }
        
        containerView.addSubview(uuidLabel)
        uuidLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        containerView.addSubview(propertiesLabel)
        propertiesLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(uuidLabel.snp.bottom).offset(4)
        }
        
        containerView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(propertiesLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        // 添加分隔线
        let separator = UIView()
        separator.backgroundColor = Color.seperatorLine
        containerView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        return containerView
    }
    
    // MARK: - Actions
    
    @objc private func characteristicItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let containerView = gesture.view else { return }
        
        let tag = containerView.tag
        let serviceIndex = tag / 1000
        let charIndex = tag % 1000
        
        guard serviceIndex < services.count,
              let characteristics = services[serviceIndex].characteristics,
              charIndex < characteristics.count else {
            return
        }
        
        let service = services[serviceIndex]
        let characteristic = characteristics[charIndex]
        
        // 跳转到特征详情页
        let characteristicVC = DeviceServiceCharacteristicViewController()
        characteristicVC.peripheral = peripheral
        characteristicVC.service = service
        characteristicVC.characteristic = characteristic
        PageManager.pushViewController(characteristicVC, animated: true)
    }
}

//
//  DeviceDetailViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/9.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool
import ExternalAccessory

class DeviceDetailViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    var device: BLEDeviceModel?
    var mfiDevice: MFIDeviceModel?
    
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
        updateDeviceInfo()
        
        // 设置连接按钮（BLE 或 MFI 设备）
        if device != nil || mfiDevice != nil {
            setupConnectButton()
        }
        
        // 只有 BLE 设备才需要回调
        if device != nil {
            setupBLEManagerCallbacks()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "设备详情"
        
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
    
    private func updateDeviceInfo() {
        // 清空之前的内容
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var lastView: UIView?
        
        // 根据设备类型显示不同的信息
        if let device = device {
            updateBLEDeviceInfo(device: device, lastView: &lastView)
        } else if let mfiDevice = mfiDevice {
            updateMFIDeviceInfo(device: mfiDevice, lastView: &lastView)
        }
        
        // 设置 contentView 的底部约束
        if let lastView = lastView {
            lastView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-16)
            }
        }
    }
    
    private func updateBLEDeviceInfo(device: BLEDeviceModel, lastView: inout UIView?) {
        // 设备基本信息
        let deviceInfoSection = createSectionView(title: "设备信息")
        contentView.addSubview(deviceInfoSection)
        deviceInfoSection.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview()
        }
        lastView = deviceInfoSection
        
        // 设备名称
        let nameItem = createInfoItem(title: "设备名称", value: device.name)
        contentView.addSubview(nameItem)
        nameItem.snp.makeConstraints { make in
            make.top.equalTo(deviceInfoSection.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        lastView = nameItem
        
        // UUID
        let uuidItem = createInfoItem(title: "UUID", value: device.identifier)
        contentView.addSubview(uuidItem)
        uuidItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = uuidItem
        
        // RSSI
        let rssiItem = createInfoItem(title: "RSSI", value: "\(device.rssi) dBm")
        contentView.addSubview(rssiItem)
        rssiItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = rssiItem
        
        // 距离
        let distanceText: String
        if device.distance < 0 {
            distanceText = "未知"
        } else if device.distance < 1 {
            distanceText = String(format: "%.2f 米", device.distance)
        } else {
            distanceText = String(format: "%.1f 米", device.distance)
        }
        let distanceItem = createInfoItem(title: "距离", value: distanceText)
        contentView.addSubview(distanceItem)
        distanceItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = distanceItem
        
        // 发现时间
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeText = dateFormatter.string(from: device.discoveredTime)
        let timeItem = createInfoItem(title: "发现时间", value: timeText)
        contentView.addSubview(timeItem)
        timeItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = timeItem
        
        // 广播信息
        if let advertisementData = device.advertisementData, !advertisementData.isEmpty {
            let broadcastSection = createSectionView(title: "广播信息")
            contentView.addSubview(broadcastSection)
            broadcastSection.snp.makeConstraints { make in
                make.top.equalTo(lastView!.snp.bottom).offset(24)
                make.left.right.equalToSuperview()
            }
            lastView = broadcastSection
            
            // 遍历广播数据
            for (key, value) in advertisementData.sorted(by: { $0.key < $1.key }) {
                let valueString = formatAdvertisementValue(value)
                let broadcastItem = createInfoItem(title: key, value: valueString)
                contentView.addSubview(broadcastItem)
                broadcastItem.snp.makeConstraints { make in
                    make.top.equalTo(lastView!.snp.bottom).offset(8)
                    make.left.right.equalToSuperview()
                }
                lastView = broadcastItem
            }
        }
    }
    
    private func updateMFIDeviceInfo(device: MFIDeviceModel, lastView: inout UIView?) {
        // 设备基本信息
        let deviceInfoSection = createSectionView(title: "设备信息")
        contentView.addSubview(deviceInfoSection)
        deviceInfoSection.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview()
        }
        lastView = deviceInfoSection
        
        // 设备名称
        let nameItem = createInfoItem(title: "设备名称", value: device.name)
        contentView.addSubview(nameItem)
        nameItem.snp.makeConstraints { make in
            make.top.equalTo(deviceInfoSection.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        lastView = nameItem
        
        // 连接ID
        let connectionIDItem = createInfoItem(title: "连接ID", value: "\(device.connectionID)")
        contentView.addSubview(connectionIDItem)
        connectionIDItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = connectionIDItem
        
        // 制造商
        let manufacturerItem = createInfoItem(title: "制造商", value: device.manufacturer)
        contentView.addSubview(manufacturerItem)
        manufacturerItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = manufacturerItem
        
        // 型号
        let modelItem = createInfoItem(title: "型号", value: device.modelNumber.isEmpty ? "未知" : device.modelNumber)
        contentView.addSubview(modelItem)
        modelItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = modelItem
        
        // 序列号
        let serialItem = createInfoItem(title: "序列号", value: device.serialNumber.isEmpty ? "未知" : device.serialNumber)
        contentView.addSubview(serialItem)
        serialItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = serialItem
        
        // 固件版本
        let firmwareItem = createInfoItem(title: "固件版本", value: device.firmwareRevision.isEmpty ? "未知" : device.firmwareRevision)
        contentView.addSubview(firmwareItem)
        firmwareItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = firmwareItem
        
        // 硬件版本
        let hardwareItem = createInfoItem(title: "硬件版本", value: device.hardwareRevision.isEmpty ? "未知" : device.hardwareRevision)
        contentView.addSubview(hardwareItem)
        hardwareItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = hardwareItem
        
        // 连接状态
        let statusItem = createInfoItem(title: "连接状态", value: device.isConnected ? "已连接" : "未连接")
        contentView.addSubview(statusItem)
        statusItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = statusItem
        
        // 发现时间
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeText = dateFormatter.string(from: device.discoveredTime)
        let timeItem = createInfoItem(title: "发现时间", value: timeText)
        contentView.addSubview(timeItem)
        timeItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = timeItem
        
        // 协议信息
        if !device.protocolStrings.isEmpty {
            let protocolSection = createSectionView(title: "协议信息")
            contentView.addSubview(protocolSection)
            protocolSection.snp.makeConstraints { make in
                make.top.equalTo(lastView!.snp.bottom).offset(24)
                make.left.right.equalToSuperview()
            }
            lastView = protocolSection
            
            // 遍历协议字符串
            for (index, protocolString) in device.protocolStrings.enumerated() {
                let protocolItem = createInfoItem(title: "协议 \(index + 1)", value: protocolString)
                contentView.addSubview(protocolItem)
                protocolItem.snp.makeConstraints { make in
                    make.top.equalTo(lastView!.snp.bottom).offset(8)
                    make.left.right.equalToSuperview()
                }
                lastView = protocolItem
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
    
    private func formatAdvertisementValue(_ value: Any) -> String {
        if let data = value as? Data {
            return data.map { String(format: "%02X", $0) }.joined(separator: " ")
        } else if let array = value as? [Any] {
            return array.map { String(describing: $0) }.joined(separator: ", ")
        } else if let dict = value as? [String: Any] {
            return dict.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        } else {
            return String(describing: value)
        }
    }
    
    // MARK: - Connect Button
    
    private func setupConnectButton() {
        var shouldShowButton = false
        
        // BLE 设备：检查是否存在 kCBAdvDataServiceUUIDs
        if let advertisementData = device?.advertisementData,
           advertisementData["kCBAdvDataServiceUUIDs"] != nil {
            shouldShowButton = true
        }
        
        // MFI 设备：检查是否已连接且有可用协议
        if let mfiDevice = mfiDevice,
           mfiDevice.isConnected,
           !mfiDevice.protocolStrings.isEmpty {
            shouldShowButton = true
        }
        
        if shouldShowButton {
            let connectButton = UIBarButtonItem(
                title: "连接设备",
                style: .plain,
                target: self,
                action: #selector(connectButtonTapped)
            )
            navigationItem.rightBarButtonItem = connectButton
        }
    }
    
    @objc private func connectButtonTapped() {
        // BLE 设备连接
        if let device = device {
            guard let peripheral = device.peripheral else {
                print("设备外设不存在")
                return
            }
            
            // 连接设备
            self.showActivity()
            BLEManager.shared.centralManager.connect(peripheral, options: nil)
            return
        }
        
        // MFI 设备连接
        if let mfiDevice = mfiDevice {
            // 检查设备是否已连接且有可用协议
            guard mfiDevice.isConnected else {
                let alert = UIAlertController(
                    title: "提示",
                    message: "设备未连接",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                present(alert, animated: true)
                return
            }
            
            guard !mfiDevice.protocolStrings.isEmpty else {
                let alert = UIAlertController(
                    title: "提示",
                    message: "设备没有可用协议",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                present(alert, animated: true)
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
                    self?.createMFISession(protocolString: protocolString)
                })
            }
            
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            
            // iPad 支持
            if let popover = alert.popoverPresentationController {
                popover.barButtonItem = navigationItem.rightBarButtonItem
            }
            
            present(alert, animated: true)
        }
    }
    
    // MARK: - BLE Manager Callbacks
    
    private func setupBLEManagerCallbacks() {
        // 设备连接成功回调
        BLEManager.shared.onDeviceConnected = { [weak self] peripheral in
            self?.hideActivity()
            guard let self = self,
                  self.device?.peripheral?.identifier == peripheral.identifier else {
                return
            }
            
            print("设备连接成功，开始发现服务...")
            // 发现服务
            peripheral.delegate = BLEManager.shared
            peripheral.discoverServices(nil)
        }
        
        // 服务发现完成回调
        BLEManager.shared.onServicesDiscovered = { [weak self] peripheral, services in
            guard let self = self,
                  self.device?.peripheral?.identifier == peripheral.identifier else {
                return
            }
            
            print("服务发现完成，共发现 \(services.count) 个服务")
            // 跳转到服务详情页
            let serviceDetailVC = DeviceServiceDetailViewController()
            serviceDetailVC.peripheral = peripheral
            serviceDetailVC.services = services
            PageManager.pushViewController(serviceDetailVC, animated: true)
        }
    }
    
    // MARK: - MFI Session
    
    private func createMFISession(protocolString: String) {
        guard let mfiDevice = mfiDevice else {
            let alert = UIAlertController(
                title: "错误",
                message: "设备不存在",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard let accessory = mfiDevice.accessory else {
            let alert = UIAlertController(
                title: "错误",
                message: "设备外设不存在",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard accessory.isConnected else {
            let alert = UIAlertController(
                title: "错误",
                message: "设备未连接",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard accessory.protocolStrings.contains(protocolString) else {
            let alert = UIAlertController(
                title: "错误",
                message: "设备不支持该协议",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 创建会话
        let session = EASession(accessory: accessory, forProtocol: protocolString)
        
        guard session != nil else {
            let alert = UIAlertController(
                title: "错误",
                message: "创建会话失败",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 跳转到会话详情页
        let detailVC = MFIDeviceConnectDetailViewController()
        detailVC.hidesBottomBarWhenPushed = true
        detailVC.device = mfiDevice
        detailVC.session = session
        detailVC.protocolString = protocolString
        PageManager.pushViewController(detailVC, animated: true)
    }
}

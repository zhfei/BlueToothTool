//
//  MFIManager.swift
//  BlueToothTool
//
//  Created by zhoufei on 2025/01/XX.
//

import Foundation
import ExternalAccessory

/// MFI 设备发现回调
public typealias MFIDeviceDiscoveredCallback = (MFIDeviceModel) -> Void

/// MFI 设备更新回调
public typealias MFIDeviceUpdatedCallback = (MFIDeviceModel) -> Void

/// MFI 设备断开回调
public typealias MFIDeviceDisconnectedCallback = (MFIDeviceModel) -> Void

/// MFI 管理工具类
public class MFIManager: NSObject {
    
    /// 单例
    public static let shared = MFIManager()
    
    /// 已发现的设备列表（使用 Set 自动去重）
    private var discoveredDevices: Set<MFIDeviceModel> = []
    
    /// 设备列表（用于返回有序列表）
    public var devices: [MFIDeviceModel] {
        return Array(discoveredDevices).sorted { $0.discoveredTime < $1.discoveredTime }
    }
    
    /// 设备发现回调
    public var onDeviceDiscovered: MFIDeviceDiscoveredCallback?
    
    /// 设备更新回调
    public var onDeviceUpdated: MFIDeviceUpdatedCallback?
    
    /// 设备断开回调
    public var onDeviceDisconnected: MFIDeviceDisconnectedCallback?
    
    private override init() {
        super.init()
        setupNotifications()
        refreshDevices()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 设置通知监听
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryDidConnect(_:)),
            name: NSNotification.Name.EAAccessoryDidConnect,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryDidDisconnect(_:)),
            name: NSNotification.Name.EAAccessoryDidDisconnect,
            object: nil
        )
    }
    
    /// 刷新设备列表
    public func refreshDevices() {
        let connectedAccessories = EAAccessoryManager.shared().connectedAccessories
        LogDebug("EA: get list \(connectedAccessories)")
        
        // 更新已存在的设备
        for accessory in connectedAccessories {
            if let existingDevice = discoveredDevices.first(where: { $0.connectionID == accessory.connectionID }) {
                // 更新现有设备信息
                existingDevice.accessory = accessory
                onDeviceUpdated?(existingDevice)
            } else {
                // 创建新设备
                let device = MFIDeviceModel(accessory: accessory)
                discoveredDevices.insert(device)
                onDeviceDiscovered?(device)
            }
        }
        
        // 移除已断开的设备
        let connectedIDs = Set(connectedAccessories.map { $0.connectionID })
        let disconnectedDevices = discoveredDevices.filter { !connectedIDs.contains($0.connectionID) }
        for device in disconnectedDevices {
            discoveredDevices.remove(device)
            onDeviceDisconnected?(device)
        }
    }
    
    /// 清空设备列表
    public func clearDevices() {
        discoveredDevices.removeAll()
    }
    
    // MARK: - Notification Handlers
    
    @objc private func accessoryDidConnect(_ notification: Notification) {
        guard let accessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let existingDevice = self.discoveredDevices.first(where: { $0.connectionID == accessory.connectionID }) {
                existingDevice.accessory = accessory
                self.onDeviceUpdated?(existingDevice)
            } else {
                let device = MFIDeviceModel(accessory: accessory)
                self.discoveredDevices.insert(device)
                self.onDeviceDiscovered?(device)
            }
        }
    }
    
    @objc private func accessoryDidDisconnect(_ notification: Notification) {
        guard let accessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let device = self.discoveredDevices.first(where: { $0.connectionID == accessory.connectionID }) {
                self.discoveredDevices.remove(device)
                self.onDeviceDisconnected?(device)
            }
        }
    }
}


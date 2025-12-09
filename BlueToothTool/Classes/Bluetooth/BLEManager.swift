//
//  BLEManager.swift
//  BlueToothTool
//
//  Created by zhoufei on 2025/01/XX.
//

import Foundation
import CoreBluetooth

/// BLE 设备发现回调
public typealias BLEDeviceDiscoveredCallback = (BLEDeviceModel) -> Void

/// BLE 设备更新回调
public typealias BLEDeviceUpdatedCallback = (BLEDeviceModel) -> Void

/// BLE 管理工具类
public class BLEManager: NSObject {
    
    /// 单例
    public static let shared = BLEManager()
    
    /// 中央管理器
    private var centralManager: CBCentralManager!
    
    /// 已发现的设备列表（使用 Set 自动去重）
    private var discoveredDevices: Set<BLEDeviceModel> = []
    
    /// 设备列表（用于返回有序列表）
    public var devices: [BLEDeviceModel] {
        return Array(discoveredDevices).sorted { $0.discoveredTime < $1.discoveredTime }
    }
    
    /// 是否正在扫描
    public var isScanning: Bool {
        return centralManager.isScanning
    }
    
    /// 设备发现回调
    public var onDeviceDiscovered: BLEDeviceDiscoveredCallback?
    
    /// 设备更新回调
    public var onDeviceUpdated: BLEDeviceUpdatedCallback?
    
    /// 蓝牙状态变化回调
    public var onBluetoothStateChanged: ((CBManagerState) -> Void)?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// 开始扫描
    /// - Parameter services: 要扫描的服务 UUID 列表，nil 表示扫描所有设备
    public func startScanning(services: [CBUUID]? = nil) {
        guard centralManager.state == .poweredOn else {
            print("蓝牙未开启，无法开始扫描")
            return
        }
        
        guard !centralManager.isScanning else {
            print("已在扫描中")
            return
        }
        
        // 清空之前的设备列表
        discoveredDevices.removeAll()
        
        // 开始扫描
        centralManager.scanForPeripherals(withServices: services, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ])
        
        print("开始扫描 BLE 设备...")
    }
    
    /// 停止扫描
    public func stopScanning() {
        guard centralManager.isScanning else {
            return
        }
        
        centralManager.stopScan()
        print("停止扫描 BLE 设备")
    }
    
    /// 清空设备列表
    public func clearDevices() {
        discoveredDevices.removeAll()
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        onBluetoothStateChanged?(state)
        
        switch state {
        case .poweredOn:
            print("蓝牙已开启")
        case .poweredOff:
            print("蓝牙已关闭")
            stopScanning()
        case .unauthorized:
            print("蓝牙未授权")
        case .unsupported:
            print("设备不支持蓝牙")
        case .resetting:
            print("蓝牙重置中")
        case .unknown:
            print("蓝牙状态未知")
        @unknown default:
            print("蓝牙状态未知")
        }
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let deviceName = peripheral.name ?? "未知设备"
        let identifier = peripheral.identifier.uuidString
        let rssi = RSSI.intValue
        
        // 查找是否已存在该设备
        if let existingDevice = discoveredDevices.first(where: { $0.identifier == identifier }) {
            // 更新现有设备
            existingDevice.updateRSSI(rssi)
            existingDevice.updateAdvertisementData(advertisementData)
            existingDevice.peripheral = peripheral
            
            // 通知更新
            onDeviceUpdated?(existingDevice)
        } else {
            // 创建新设备
            let device = BLEDeviceModel(
                name: deviceName,
                identifier: identifier,
                rssi: rssi,
                advertisementData: advertisementData,
                peripheral: peripheral
            )
            
            discoveredDevices.insert(device)
            
            // 通知发现新设备
            onDeviceDiscovered?(device)
        }
    }
}


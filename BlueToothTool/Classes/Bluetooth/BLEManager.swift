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
public typealias BLEVoidCallback = () -> Void

/// BLE 管理工具类
public class BLEManager: NSObject {
    
    /// 单例
    public static let shared = BLEManager()
    
    /// 中央管理器
    public var centralManager: CBCentralManager!
    
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
    
    /// 设备更新回调
    public var onStopScan: BLEVoidCallback?
    
    /// 蓝牙状态变化回调
    public var onBluetoothStateChanged: ((CBManagerState) -> Void)?
    
    /// 设备连接成功回调
    public var onDeviceConnected: ((CBPeripheral) -> Void)?
    
    /// 服务发现完成回调
    public var onServicesDiscovered: ((CBPeripheral, [CBService]) -> Void)?
    
    /// 特征发现完成回调
    public var onCharacteristicsDiscovered: ((CBService, [CBCharacteristic]) -> Void)?
    
    /// 特征值更新回调
    public var onCharacteristicValueUpdated: ((CBCharacteristic, Data?) -> Void)?
    
    /// 特征写入完成回调
    public var onCharacteristicWriteCompleted: ((CBCharacteristic, Error?) -> Void)?
    
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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {[weak self] in
            self?.stopScanning()
        })
        
        print("开始扫描 BLE 设备...")
    }
    
    /// 停止扫描
    public func stopScanning() {
        guard centralManager.isScanning else {
            return
        }
        
        centralManager.stopScan()
        
        onStopScan?()
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
        LogDebug("1.扫描设备(success)：peripheral:\(peripheral) - advertisementData:\(advertisementData) - RSSI:\(RSSI)")
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
    
    // 连接成功
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        LogDebug("2.连接设备(success)：peripheral:\(peripheral)")
        print("BLE 连接成功 ✅")
        DispatchQueue.main.async { [weak self] in
            self?.onDeviceConnected?(peripheral)
        }
    }


     public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
         print("BLE 已断开 ❌")
     }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("BLE 连接失败 \(error)")
    }
}

extension BLEManager: CBPeripheralDelegate {
    // peripheral.delegate 的 方法实现。
     // MARK: - CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        LogDebug("3.查询服务(success)：peripheral:\(peripheral.services)")
        let services = peripheral.services ?? []
        print("发现服务数量: \(services.count)")
        for service in services {
            print("发现服务: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onServicesDiscovered?(peripheral, services)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral,
                        didDiscoverCharacteristicsFor service: CBService,
                        error: Error?) {
        LogDebug("4.查询特征(success)：service:\(service)")
        let characteristics = service.characteristics ?? []
        for characteristic in characteristics {
            print("发现特征: \(characteristic.uuid)")
            // 读取特征值
            peripheral.readValue(for: characteristic)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onCharacteristicsDiscovered?(service, characteristics)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral,
                        didUpdateValueFor characteristic: CBCharacteristic,
                        error: Error?) {
        LogDebug("5.订阅特征(success)：characteristic:\(characteristic)")
        if let data = characteristic.value {
            print("收到特征数据: \(data)")
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onCharacteristicValueUpdated?(characteristic, characteristic.value)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral,
                        didWriteValueFor characteristic: CBCharacteristic,
                        error: Error?) {
        LogDebug("5.1.写特征(success)：characteristic:\(characteristic)")
        if let error = error {
            print("写入特征失败: \(error)")
        } else {
            print("写入特征成功")
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onCharacteristicWriteCompleted?(characteristic, error)
        }
    }
}


//
//  BLEDeviceModel.swift
//  BlueToothTool
//
//  Created by zhoufei on 2025/01/XX.
//

import Foundation
import CoreBluetooth

/// BLE 设备模型
public class BLEDeviceModel {
    /// 设备名称
    public var name: String
    
    /// 设备 UUID（identifier）
    public var identifier: String
    
    /// RSSI 信号强度
    public var rssi: Int
    
    /// 距离估算（米）
    public var distance: Double {
        return calculateDistance(rssi: rssi)
    }
    
    /// 广播数据
    public var advertisementData: [String: Any]?
    
    /// 外设对象
    public var peripheral: CBPeripheral?
    
    /// 发现时间
    public var discoveredTime: Date
    
    /// 初始化
    public init(
        name: String,
        identifier: String,
        rssi: Int,
        advertisementData: [String: Any]? = nil,
        peripheral: CBPeripheral? = nil
    ) {
        self.name = name
        self.identifier = identifier
        self.rssi = rssi
        self.advertisementData = advertisementData
        self.peripheral = peripheral
        self.discoveredTime = Date()
    }
    
    /// 基于 RSSI 计算距离
    /// - Parameter rssi: 信号强度
    /// - Returns: 距离（米）
    private func calculateDistance(rssi: Int) -> Double {
        // 使用标准公式：distance = 10^((TxPower - RSSI) / (10 * n))
        // TxPower 通常为 -59 dBm（1米处的信号强度）
        // n 为路径损耗指数，通常为 2-4，这里使用 2
        let txPower: Double = -59.0
        let n: Double = 2.0
        
        if rssi == 0 {
            return -1.0 // 无效信号
        }
        
        let ratio = (txPower - Double(rssi)) / (10.0 * n)
        let distance = pow(10.0, ratio)
        
        // 限制最大显示距离为 100 米
        return min(distance, 100.0)
    }
    
    /// 更新 RSSI 值
    public func updateRSSI(_ rssi: Int) {
        self.rssi = rssi
    }
    
    /// 更新广播数据
    public func updateAdvertisementData(_ data: [String: Any]?) {
        self.advertisementData = data
    }
}

extension BLEDeviceModel: Equatable {
    public static func == (lhs: BLEDeviceModel, rhs: BLEDeviceModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension BLEDeviceModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}


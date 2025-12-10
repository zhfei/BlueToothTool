//
//  MFIDeviceModel.swift
//  BlueToothTool
//
//  Created by zhoufei on 2025/01/XX.
//

import Foundation
import ExternalAccessory

/// MFI 设备模型
public class MFIDeviceModel {
    /// 设备名称
    public var name: String
    
    /// 设备连接ID
    public var connectionID: Int
    
    /// 制造商
    public var manufacturer: String
    
    /// 型号
    public var modelNumber: String
    
    /// 序列号
    public var serialNumber: String
    
    /// 固件版本
    public var firmwareRevision: String
    
    /// 硬件版本
    public var hardwareRevision: String
    
    /// 协议字符串列表
    public var protocolStrings: [String]
    
    /// 外设对象
    public var accessory: EAAccessory?
    
    /// 发现时间
    public var discoveredTime: Date
    
    /// 是否已连接
    public var isConnected: Bool {
        return accessory?.isConnected ?? false
    }
    
    /// 初始化
    public init(
        name: String,
        connectionID: Int,
        manufacturer: String,
        modelNumber: String,
        serialNumber: String,
        firmwareRevision: String,
        hardwareRevision: String,
        protocolStrings: [String],
        accessory: EAAccessory? = nil
    ) {
        self.name = name
        self.connectionID = connectionID
        self.manufacturer = manufacturer
        self.modelNumber = modelNumber
        self.serialNumber = serialNumber
        self.firmwareRevision = firmwareRevision
        self.hardwareRevision = hardwareRevision
        self.protocolStrings = protocolStrings
        self.accessory = accessory
        self.discoveredTime = Date()
    }
    
    /// 从 EAAccessory 创建设备模型
    public convenience init(accessory: EAAccessory) {
        self.init(
            name: accessory.name,
            connectionID: accessory.connectionID,
            manufacturer: accessory.manufacturer,
            modelNumber: accessory.modelNumber,
            serialNumber: accessory.serialNumber,
            firmwareRevision: accessory.firmwareRevision,
            hardwareRevision: accessory.hardwareRevision,
            protocolStrings: accessory.protocolStrings,
            accessory: accessory
        )
    }
}

extension MFIDeviceModel: Equatable {
    public static func == (lhs: MFIDeviceModel, rhs: MFIDeviceModel) -> Bool {
        return lhs.connectionID == rhs.connectionID
    }
}

extension MFIDeviceModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(connectionID)
    }
}


//
//  Double+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension Double {
    func toString(decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }

    var removeTrailingZeros: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16  // 根据需求设置合适的最大小数位数
        formatter.numberStyle = .decimal

        if let result = formatter.string(from: self as NSNumber) {
            return result
        } else {
            return String(self)
        }
    }
}

extension Double {

    func remainingTime() -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = Int(self) / 3600
        let minutes = (Int(self) / 60) % 60
        let seconds = Int(self) % 60
        return (hours: hours, minutes: minutes, seconds: seconds)
    }
}

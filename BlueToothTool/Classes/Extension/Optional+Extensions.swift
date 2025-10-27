//
//  Optional+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension Optional where Wrapped == Any {
    func toString() -> String {
        if let value = self {
            return String(describing: value)
        } else {
            return ""
        }
    }
}

extension Optional where Wrapped == Int {
    func toString() -> String? {
        guard let value = self else {
            return nil
        }
        return String(value)
    }
}

extension Optional where Wrapped == String {
    func toInt() -> Int? {
        guard let value = self else {
            return nil
        }
        return Int(value)
    }
}

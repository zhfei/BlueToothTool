//
//  DispatchQueue+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit


extension DispatchQueue {
    func asyncAfter(delay: Double, execute closure: @escaping () -> Void) {
        self.asyncAfter(deadline: .now() + delay, execute: closure)
    }

    public static func asyncInMainQueue(_ workItem: @escaping () -> Void) {
        if DispatchQueue.isMainQueue {
            workItem()
        } else {
            DispatchQueue.main.async(execute: workItem)
        }
    }
}

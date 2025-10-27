//
//  Int+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension Int {

    var hourToSecondDescription: String {
        if self > 3600 {
            let hours = self / 3600
            let minutes = (self % 3600) / 60
            let seconds = (self % 3600) % 60

            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            let minutes = self / 60
            let seconds = self % 60

            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

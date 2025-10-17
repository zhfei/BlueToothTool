//
//  UIWindow+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/9/17.
//

import UIKit

extension UIWindow {
    // 获取当前的 keyWindow
    static func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            // iOS 13 及更高版本通过 SceneDelegate 获取
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            // iOS 13 之前版本直接使用 keyWindow
            return UIApplication.shared.keyWindow
        }
    }
}

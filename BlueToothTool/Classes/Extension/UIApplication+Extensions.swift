//
//  UIApplication+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension UIApplication {

    var safeAreaInsetsTop: CGFloat {
        return UIApplication.shared.currentWindow?.safeAreaInsets.top ?? 0
    }

    var safeAreaInsetsBottom: CGFloat {
        return UIApplication.shared.currentWindow?.safeAreaInsets.bottom ?? 0
    }

    var statusBarHeight: CGFloat {
        let statusBarHeight =
            UIApplication.shared.currentWindow?.windowScene?.statusBarManager?.statusBarFrame.height
            ?? 0
        return statusBarHeight
    }
}

extension UIApplication {
    var currentWindow: UIWindow? {
        return
            connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })
    }
}

extension UIApplication {
    var hasNotch: Bool {
        if let window = UIApplication.shared.currentWindow {
            return window.safeAreaInsets.top > 20  // Adjust this value based on the actual notch height
        }
        return false
    }
}

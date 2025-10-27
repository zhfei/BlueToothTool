//
//  UIButton+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: state)
    }
}

extension UIButton {
    func addHitTestEdgeInsets(_ insets: UIEdgeInsets) {
        let hitRect = bounds.inset(by: insets)
        let hitView = UIButtonExtensionHitView(frame: hitRect)
        addSubview(hitView)
    }

    private class UIButtonExtensionHitView: UIView {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return true
        }
    }
}

extension UIButton {
    func setImageWithHighlightedTint(_ image: UIImage?) {
        setImage(image, for: .normal)
        setImage(image?.tintWithColor(Color.grayLightText), for: .highlighted)
    }
}

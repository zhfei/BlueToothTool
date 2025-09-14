//
//  UIView+Extensions.swift
//  RepReady
//
//  Created by 周飞 on 2025/8/22.
//

import UIKit

extension UIView {
    
    // MARK: - Frame Properties
    
    /// 快速访问和设置 x 坐标
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    /// 快速访问和设置 y 坐标
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    /// 快速访问和设置宽度
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    /// 快速访问和设置高度
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    /// 快速访问和设置 size
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    /// 快速访问和设置 origin
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }
    
    /// 快速访问和设置 centerX
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center.x = newValue
        }
    }
    
    /// 快速访问和设置 centerY
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center.y = newValue
        }
    }
    
    /// 快速访问和设置右边距
    var right: CGFloat {
        get {
            return x + width
        }
        set {
            x = newValue - width
        }
    }
    
    /// 快速访问和设置下边距
    var bottom: CGFloat {
        get {
            return y + height
        }
        set {
            y = newValue - height
        }
    }
    
    // MARK: - Convenience Methods
    
    /// 设置 frame 的所有属性
    func setFrame(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    /// 设置 size
    func setSize(width: CGFloat, height: CGFloat) {
        size = CGSize(width: width, height: height)
    }
    
    /// 设置 origin
    func setOrigin(x: CGFloat, y: CGFloat) {
        origin = CGPoint(x: x, y: y)
    }
    
    /// 设置 center
    func setCenter(x: CGFloat, y: CGFloat) {
        center = CGPoint(x: x, y: y)
    }
}

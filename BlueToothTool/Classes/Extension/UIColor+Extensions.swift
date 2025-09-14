//
//  UIColor+Extensions.swift
//  RepReady
//
//  Created by 周飞 on 2025/8/23.
//

import UIKit

extension UIColor {
    
    // MARK: - Hex Color Initialization
    
    /// 使用 hex 字符串初始化 UIColor
    /// - Parameter hex: hex 字符串，支持 "#FFFFFF"、"FFFFFF"、"#FFF"、"FFF" 等格式
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RRGGBBAA
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
    
    /// 使用 hex 整数值初始化 UIColor
    /// - Parameter hex: hex 整数值，例如 0xFFFFFF
    convenience init(hex: Int) {
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = hex & 0xFF
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
    
    /// 使用 hex 整数值和透明度初始化 UIColor
    /// - Parameters:
    ///   - hex: hex 整数值，例如 0xFFFFFF
    ///   - alpha: 透明度，范围 0.0-1.0
    convenience init(hex: Int, alpha: CGFloat) {
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = hex & 0xFF
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: alpha
        )
    }
    
    // MARK: - Hex Color Conversion
    
    /// 获取 UIColor 的 hex 字符串表示（不包含透明度）
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255)
        
        return String(format: "#%06x", rgb).uppercased()
    }
    
    /// 获取 UIColor 的 hex 字符串表示（包含透明度）
    var hexStringWithAlpha: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgba = Int(r * 255) << 24 | Int(g * 255) << 16 | Int(b * 255) << 8 | Int(a * 255)
        
        return String(format: "#%08x", rgba).uppercased()
    }
    
    /// 获取 UIColor 的 hex 整数值（不包含透明度）
    var hexValue: Int {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255)
    }
    
    // MARK: - Convenience Methods
    
    /// 使用 hex 字符串创建 UIColor（静态方法）
    /// - Parameter hex: hex 字符串
    /// - Returns: UIColor 实例
    static func hex(_ hex: String) -> UIColor {
        return UIColor(hex: hex)
    }
    
    /// 使用 hex 整数值创建 UIColor（静态方法）
    /// - Parameter hex: hex 整数值
    /// - Returns: UIColor 实例
    static func hex(_ hex: Int) -> UIColor {
        return UIColor(hex: hex)
    }
    
    /// 使用 hex 整数值和透明度创建 UIColor（静态方法）
    /// - Parameters:
    ///   - hex: hex 整数值
    ///   - alpha: 透明度
    /// - Returns: UIColor 实例
    static func hex(_ hex: Int, alpha: CGFloat) -> UIColor {
        return UIColor(hex: hex, alpha: alpha)
    }
}

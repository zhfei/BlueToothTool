//
//  DTCoreTextHelper.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/18.
//

import UIKit
import DTCoreText
import SnapKit

/// DTCoreText 工具类 - 专门处理后台返回的标签字符串
class DTCoreTextHelper {
    
    // MARK: - 配置选项
    
    /// 预设的样式配置
    struct StyleConfig {
        let fontSize: CGFloat
        let fontFamily: String
        let textColor: UIColor
        let linkColor: UIColor
        let lineHeight: CGFloat
        let textAlignment: NSTextAlignment
        
        static let `default` = StyleConfig(
            fontSize: 14,
            fontFamily: "-apple-system",
            textColor: Color.grayLightText,
            linkColor: Color.lakeBlue,
            lineHeight: 1.5,
            textAlignment: .left
        )
        
        static let title = StyleConfig(
            fontSize: 16,
            fontFamily: "-apple-system",
            textColor: Color.primaryText,
            linkColor: Color.lakeBlue,
            lineHeight: 1.4,
            textAlignment: .left
        )
        
        static let subtitle = StyleConfig(
            fontSize: 12,
            fontFamily: "-apple-system",
            textColor: Color.grayText,
            linkColor: Color.lakeBlue,
            lineHeight: 1.3,
            textAlignment: .left
        )
    }
    
    // MARK: - 公共方法
    
    /// 创建并配置 DTAttributedLabel
    /// - Parameters:
    ///   - htmlString: 后台返回的 HTML 标签字符串
    ///   - styleConfig: 样式配置，默认使用 default 配置
    ///   - maxWidth: 最大宽度，用于计算高度
    /// - Returns: 配置好的 DTAttributedLabel
    static func createAttributedLabel(
        htmlString: String,
        styleConfig: StyleConfig = .default,
        maxWidth: CGFloat = UIScreen.main.bounds.width - 32
    ) -> DTAttributedLabel {
        let label = DTAttributedLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        // 设置富文本内容
        let attributedString = createAttributedString(from: htmlString, styleConfig: styleConfig)
        label.attributedString = attributedString
        
        return label
    }
    
    /// 计算 HTML 字符串的高度
    /// - Parameters:
    ///   - htmlString: 后台返回的 HTML 标签字符串
    ///   - styleConfig: 样式配置，默认使用 default 配置
    ///   - maxWidth: 最大宽度
    /// - Returns: 计算出的高度
    static func calculateHeight(
        for htmlString: String,
        styleConfig: StyleConfig = .default,
        maxWidth: CGFloat = UIScreen.main.bounds.width - 32
    ) -> CGFloat {
        let attributedString = createAttributedString(from: htmlString, styleConfig: styleConfig)
        return calculateHeight(for: attributedString, maxWidth: maxWidth)
    }
    
    /// 计算 NSAttributedString 的高度
    /// - Parameters:
    ///   - attributedString: 富文本字符串
    ///   - maxWidth: 最大宽度
    /// - Returns: 计算出的高度
    static func calculateHeight(
        for attributedString: NSAttributedString,
        maxWidth: CGFloat
    ) -> CGFloat {
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = attributedString.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(boundingBox.height)
    }
    
    /// 创建 NSAttributedString
    /// - Parameters:
    ///   - htmlString: HTML 字符串
    ///   - styleConfig: 样式配置
    /// - Returns: NSAttributedString
    static func createAttributedString(
        from htmlString: String,
        styleConfig: StyleConfig
    ) -> NSAttributedString {
        // 包装 HTML 字符串，添加基础样式
        let wrappedHTML = wrapHTMLString(htmlString, with: styleConfig)
        
        // 配置解析选项
        let options: [String: Any] = [
            DTDefaultFontSize: styleConfig.fontSize,
            DTDefaultFontFamily: styleConfig.fontFamily,
            DTDefaultTextColor: styleConfig.textColor,
            DTDefaultLinkColor: styleConfig.linkColor,
            DTDefaultLinkHighlightColor: styleConfig.linkColor.withAlphaComponent(0.3),
            DTUseiOS6Attributes: true,
            DTDefaultLineHeightMultiplier: styleConfig.lineHeight,
            DTDefaultTextAlignment: styleConfig.textAlignment.rawValue
        ]
        
        // 解析 HTML
        guard let attributedString = NSAttributedString(
            htmlData: wrappedHTML.data(using: .utf8),
            options: options,
            documentAttributes: nil
        ) else {
            // 如果解析失败，返回普通文本
            return NSAttributedString(
                string: htmlString,
                attributes: [
                    .font: UIFont.systemFont(ofSize: styleConfig.fontSize),
                    .foregroundColor: styleConfig.textColor
                ]
            )
        }
        
        return attributedString
    }
    
    // MARK: - 私有方法
    
    /// 包装 HTML 字符串，添加基础样式
    /// - Parameters:
    ///   - htmlString: 原始 HTML 字符串
    ///   - styleConfig: 样式配置
    /// - Returns: 包装后的 HTML 字符串
    private static func wrapHTMLString(_ htmlString: String, with styleConfig: StyleConfig) -> String {
        // 如果字符串已经包含完整的 HTML 结构，直接返回
        if htmlString.lowercased().contains("<html") || htmlString.lowercased().contains("<body") {
            return htmlString
        }
        
        // 包装成完整的 HTML 结构
        let wrappedHTML = """
        <div style="font-family: \(styleConfig.fontFamily); font-size: \(styleConfig.fontSize)px; color: \(styleConfig.textColor.toHexString()); line-height: \(styleConfig.lineHeight); text-align: \(textAlignmentToString(styleConfig.textAlignment));">
            \(htmlString)
        </div>
        """
        
        return wrappedHTML
    }
    
    /// 将 NSTextAlignment 转换为 CSS 字符串
    /// - Parameter alignment: 文本对齐方式
    /// - Returns: CSS 对齐字符串
    private static func textAlignmentToString(_ alignment: NSTextAlignment) -> String {
        switch alignment {
        case .left:
            return "left"
        case .center:
            return "center"
        case .right:
            return "right"
        case .justified:
            return "justify"
        default:
            return "left"
        }
    }
}

// MARK: - 扩展方法

extension DTCoreTextHelper {
    
    /// 快速创建标签视图（用于展示后台返回的标签数据）
    /// - Parameters:
    ///   - htmlString: 后台返回的 HTML 标签字符串
    ///   - styleConfig: 样式配置
    ///   - maxWidth: 最大宽度
    /// - Returns: 配置好的标签视图
    static func createTagView(
        htmlString: String,
        styleConfig: StyleConfig = .default,
        maxWidth: CGFloat = UIScreen.main.bounds.width - 32
    ) -> UIView {
        let containerView = UIView()
        let label = createAttributedLabel(htmlString: htmlString, styleConfig: styleConfig, maxWidth: maxWidth)
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return containerView
    }
    
    /// 批量计算多个 HTML 字符串的高度
    /// - Parameters:
    ///   - htmlStrings: HTML 字符串数组
    ///   - styleConfig: 样式配置
    ///   - maxWidth: 最大宽度
    /// - Returns: 高度数组
    static func calculateHeights(
        for htmlStrings: [String],
        styleConfig: StyleConfig = .default,
        maxWidth: CGFloat = UIScreen.main.bounds.width - 32
    ) -> [CGFloat] {
        return htmlStrings.map { htmlString in
            calculateHeight(for: htmlString, styleConfig: styleConfig, maxWidth: maxWidth)
        }
    }
}

// MARK: - UIColor 扩展

extension UIColor {
    /// 将 UIColor 转换为十六进制字符串
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}

// MARK: - 使用示例

/*
// 使用示例：

// 1. 基础使用 - 创建标签
let htmlString = "<p>这是一段包含 <strong>粗体</strong> 和 <em>斜体</em> 的文本</p>"
let label = DTCoreTextHelper.createAttributedLabel(htmlString: htmlString)

// 2. 自定义样式
let customConfig = DTCoreTextHelper.StyleConfig(
    fontSize: 16,
    fontFamily: "-apple-system",
    textColor: Color.primaryText,
    linkColor: Color.lakeBlue,
    lineHeight: 1.6,
    textAlignment: .center
)
let customLabel = DTCoreTextHelper.createAttributedLabel(
    htmlString: htmlString,
    styleConfig: customConfig
)

// 3. 计算高度
let height = DTCoreTextHelper.calculateHeight(for: htmlString, maxWidth: 300)

// 4. 创建标签视图
let tagView = DTCoreTextHelper.createTagView(htmlString: htmlString)

// 5. 批量计算高度
let htmlStrings = ["<p>文本1</p>", "<p>文本2</p>", "<p>文本3</p>"]
let heights = DTCoreTextHelper.calculateHeights(for: htmlStrings)

// 6. 在 TableView Cell 中使用
class MyTableViewCell: UITableViewCell {
    private let contentLabel = DTAttributedLabel()
    
    func configure(with htmlString: String) {
        let attributedString = DTCoreTextHelper.createAttributedString(
            from: htmlString,
            styleConfig: .default
        )
        contentLabel.attributedString = attributedString
    }
    
    static func height(for htmlString: String, maxWidth: CGFloat) -> CGFloat {
        return DTCoreTextHelper.calculateHeight(for: htmlString, maxWidth: maxWidth)
    }
}
*/

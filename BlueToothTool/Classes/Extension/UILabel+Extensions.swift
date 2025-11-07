//
//  UILabel+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/18.
//

import UIKit
import Down

//!!!: UILabel 文本高度计算
extension UILabel {
    
    /// 计算 UILabel 在指定宽度下的尺寸
    /// - Parameters:
    ///   - maxWidth: 最大宽度
    ///   - options: 文本绘制选项，默认为 [.usesLineFragmentOrigin, .usesFontLeading]
    /// - Returns: 计算出的尺寸
    func calculateSize(
        maxWidth: CGFloat,
        options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
    ) -> CGSize {
        guard let text = self.text, !text.isEmpty else {
            return CGSize.zero
        }
        
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: options,
            attributes: [.font: self.font ?? UIFont.systemFont(ofSize: 17)],
            context: nil
        )
        return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
    
    
    /// 计算 UILabel 富文本在指定宽度下的尺寸
    /// - Parameters:
    ///   - maxWidth: 最大宽度
    ///   - options: 文本绘制选项，默认为 [.usesLineFragmentOrigin, .usesFontLeading]
    /// - Returns: 计算出的尺寸
    func calculateAttributedTextSize(
        maxWidth: CGFloat,
        options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
    ) -> CGSize {
        guard let attributedText = self.attributedText, attributedText.length > 0 else {
            return CGSize.zero
        }
        
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = attributedText.boundingRect(
            with: constraintRect,
            options: options,
            context: nil
        )
        return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
    
    /// 使用 sizeThatFits 计算尺寸（推荐用于多行文本）
    /// - Parameter maxWidth: 最大宽度
    /// - Returns: 计算出的尺寸
    func calculateSizeWithSizeThatFits(maxWidth: CGFloat) -> CGSize {
        return self.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
    }
}


//!!!: Markdown 文本展示

extension UILabel {
    // MARK: - Markdown 处理
    
    /// 创建格式化的 NSAttributedString（共享逻辑）
    /// - Parameter markdownString: Markdown 格式的字符串
    /// - Returns: 格式化后的 NSAttributedString，失败时返回 nil
    public func createFormattedAttributedString(from markdownString: String) -> NSMutableAttributedString? {
        do {
            // 使用 Down 解析 Markdown
            let down = Down(markdownString: markdownString)
            let attributedString = try down.toAttributedString()
            
            // 创建可变副本以便修改样式
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            
            // 获取 label 的默认样式
            let defaultFont = self.font ?? UIFont.systemFont(ofSize: 10)
            let defaultColor = self.textColor ?? Color.white
            let textAlignment = self.textAlignment
            
            // 创建段落样式以支持对齐
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            paragraphStyle.lineSpacing = 2.0 // 设置行间距
            paragraphStyle.paragraphSpacing = 4.0 // 设置段落间距
            
            // 为整个文本范围应用默认样式
            let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
            
            // 先为整个文本应用默认字体和颜色（作为基础样式）
            mutableAttributedString.addAttribute(.font, value: defaultFont, range: fullRange)
            mutableAttributedString.addAttribute(.foregroundColor, value: defaultColor, range: fullRange)
            
            // 然后重新应用 markdown 解析出的特殊格式（如粗体、斜体等）
            // 重要：只保留字体格式和链接颜色，不重新应用普通文本的颜色
            attributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
                // 保留字体属性（粗体、斜体等格式）
                if let font = attributes[.font] as? UIFont {
                    mutableAttributedString.addAttribute(.font, value: font, range: range)
                }
                
                // 只保留链接的颜色，普通文本使用默认颜色
                // 如果该范围是链接，则保留链接的颜色
                if let link = attributes[.link] {
                    // 这是链接，保留链接的颜色（如果存在）
                    if let linkColor = attributes[.foregroundColor] as? UIColor {
                        mutableAttributedString.addAttribute(.foregroundColor, value: linkColor, range: range)
                    }
                    // 保留链接属性本身
                    mutableAttributedString.addAttribute(.link, value: link, range: range)
                }
                // 普通文本不重新应用颜色，使用上面设置的默认颜色
            }
            
            // 应用段落样式（包括对齐方式）
            mutableAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
            
            return mutableAttributedString
        } catch {
            // 解析失败时返回 nil
            print("[PracticeProgressTableViewCell] Markdown 解析失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 计算 Markdown 文本的高度
    /// - Parameters:
    ///   - markdownString: Markdown 格式的字符串
    ///   - maxWidth: 最大宽度
    /// - Returns: 计算出的高度
    public func calculateMarkdownHeight(markdownString: String, maxWidth: CGFloat) -> CGFloat {
        // 使用共享逻辑创建格式化的 NSAttributedString
        guard let attributedString = createFormattedAttributedString(from: markdownString) else {
            // 解析失败时，使用普通文本高度计算作为后备
            let defaultFont = self.font ?? UIFont.systemFont(ofSize: 10)
            let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
            let boundingBox = markdownString.boundingRect(
                with: constraintRect,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: defaultFont],
                context: nil
            )
            return ceil(boundingBox.height)
        }
        
        // 使用 boundingRect 计算 NSAttributedString 的高度
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = attributedString.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(boundingBox.height)
    }
    
    /// 使用 Down 库解析 Markdown 并应用到 contentLabel
    /// - Parameter markdownString: Markdown 格式的字符串
    public func setMarkdownTextForLabel(_ markdownString: String) {
        // 使用共享逻辑创建格式化的 NSAttributedString
        if let attributedString = createFormattedAttributedString(from: markdownString) {
            self.attributedText = attributedString
        } else {
            // 解析失败时显示原始文本
            self.text = markdownString
        }
    }
}

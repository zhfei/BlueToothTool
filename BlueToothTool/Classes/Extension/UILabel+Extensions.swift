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
    
    /// 预处理 Markdown 字符串
    /// - Parameter markdownString: 原始 Markdown 字符串
    /// - Returns: 预处理后的字符串
    /// - Note: 支持连续多个转义换行符，如 "\\n\\n\\n" 会转换为保留三个空行的格式
    private func preprocessMarkdownNewlines(_ markdownString: String) -> String {
        // 使用正则表达式匹配连续的 \\n（在字符串中 \\n 是字面量 \n）
        // 正则表达式需要匹配字面量 \n，所以使用 \\\\n（四个反斜杠+n）
        do {
            // 匹配连续的 \\n（1个或多个）
            // 在 Swift 字符串中，\\\\n 表示正则表达式中的 \\n，匹配字符串中的字面量 \n
            let regex = try NSRegularExpression(pattern: "(\\\\n)+", options: [])
            let nsString = markdownString as NSString
            let range = NSRange(location: 0, length: nsString.length)
            
            // 获取所有匹配结果
            let matches = regex.matches(in: markdownString, options: [], range: range)
            
            LogDebug("markdownString: \(markdownString)")
            LogDebug("matches: \(matches)")
            
            // 如果没有匹配到，直接返回原字符串
            guard !matches.isEmpty else {
                return markdownString
            }
            
            // 反向遍历匹配结果，从后往前替换，避免索引变化问题
            var processed = markdownString
            let nsMutableString = NSMutableString(string: processed)
            
            for (index,match) in matches.enumerated().reversed() {
                let matchRange = match.range
                let matchedText = nsString.substring(with: matchRange)
                
                // 计算连续 \\n 的数量（每个 \\n 是2个字符：\ 和 n）
                let newlineCount = matchedText.count / 2
                
                // 根据数量进行转换
                // 统一所有数量的连续换行符都转换为对应数量的硬换行（两个空格+换行符）
                // 1个 \\n → "  \n"（1个硬换行）
                // 2个 \\n → "  \n  \n"（2个硬换行）
                // 3个及以上 \\n → 对应数量的 "  \n"（多个硬换行）
                let replacement = String(repeating: "  \n", count: newlineCount)
                
                // 替换匹配到的内容
                nsMutableString.replaceCharacters(in: matchRange, with: replacement)
                
                LogDebug("nsMutableString: \(nsMutableString) - newlineCount:\(newlineCount) - index:\(index) - match:\(match)")
            }
            
            
            processed = nsMutableString as String
            
            LogDebug("processed: \(processed)")
            return processed
        } catch {
            // 如果正则表达式失败，返回原字符串
            print("[UILabel+Extensions] Markdown 预处理正则表达式失败: \(error.localizedDescription)")
            return markdownString
        }
    }
    
    /// 创建格式化的 NSAttributedString（共享逻辑）
    /// - Parameter markdownString: Markdown 格式的字符串
    /// - Returns: 格式化后的 NSAttributedString，失败时返回 nil
    public func createFormattedAttributedString(from markdownString: String) -> NSMutableAttributedString? {
        do {
            // 预处理 Markdown 字符串（处理转义换行符和单个换行符）
            let processedMarkdown = preprocessMarkdownNewlines(markdownString)
            
            // 使用 Down 解析 Markdown
            let down = Down(markdownString: processedMarkdown)
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

extension UILabel {
    /// 设置 UILabel 的行高和对齐方式
    /// - Parameters:
    ///   - lineHeight: 行高值（CGFloat）
    ///   - alignment: 文字对齐方式，默认为 nil（使用 label 的当前 textAlignment）
    /// - Note: 如果 label 已有 text，会创建 attributedText；如果已有 attributedText，会更新其段落样式
    public func setLineHeight(_ lineHeight: CGFloat, alignment: NSTextAlignment? = nil) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        // 确定对齐方式
        let textAlignment: NSTextAlignment
        if let alignment = alignment {
            // 使用传入的对齐方式
            textAlignment = alignment
        } else if let attributedText = self.attributedText,
                  let existingParagraphStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            // 如果已有 attributedText，尝试从段落样式中提取对齐方式
            textAlignment = existingParagraphStyle.alignment
        } else {
            // 使用 label 的当前对齐方式
            textAlignment = self.textAlignment
        }
        paragraphStyle.alignment = textAlignment
        
        // 获取当前文本和样式
        let currentText: String
        let currentFont: UIFont
        let currentColor: UIColor
        
        if let attributedText = self.attributedText {
            // 如果已有 attributedText，提取文本和样式
            currentText = attributedText.string
            currentFont = attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont ?? self.font ?? UIFont.systemFont(ofSize: 17)
            currentColor = attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? self.textColor ?? UIColor.black
        } else if let text = self.text {
            // 如果只有 text，使用当前 label 的样式
            currentText = text
            currentFont = self.font ?? UIFont.systemFont(ofSize: 17)
            currentColor = self.textColor ?? UIColor.black
        } else {
            // 如果没有文本，直接返回
            return
        }
        
        // 创建新的 attributedString
        let attributedString = NSAttributedString(
            string: currentText,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: currentColor,
                .font: currentFont
            ]
        )
        
        self.attributedText = attributedString
    }
}

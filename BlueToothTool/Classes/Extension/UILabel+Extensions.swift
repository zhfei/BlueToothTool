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
    static let PlaceStringWord = "换行占位"
    static let PlaceString = " \n \(UILabel.PlaceStringWord) \n"
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
                
                // 第一步：将每个 \\n 转换为标准的 markdown 硬换行格式 " \n"（一个空格+换行符）
                // 1个 \\n → " \n"（1个硬换行）
                // 2个 \\n → " \n \n"（2个硬换行）
                // 3个及以上 \\n → 对应数量的 " \n"（多个硬换行）
                let markdownNewlines = String(repeating: " \n", count: newlineCount)
                
                // 替换匹配到的内容
                nsMutableString.replaceCharacters(in: matchRange, with: markdownNewlines)
                
                LogDebug("nsMutableString after step1: \(nsMutableString) - newlineCount:\(newlineCount) - index:\(index)")
            }
            
            processed = nsMutableString as String
            
            // 第二步：将所有 " \n" 替换为占位字符串 PlaceString
            // 使用正则表达式匹配 " \n"（一个空格+换行符）
            let placeholderRegex = try NSRegularExpression(pattern: " \n", options: [])
            let processedNsString = processed as NSString
            let processedRange = NSRange(location: 0, length: processedNsString.length)
            let placeholderMatches = placeholderRegex.matches(in: processed, options: [], range: processedRange)
            
            guard !placeholderMatches.isEmpty else {
            LogDebug("processed: \(processed)")
            return processed
            }
            
            let finalMutableString = NSMutableString(string: processed)
            let placeholder = UILabel.PlaceString
            
            // 定义连续区间结构体，用于保存连续出现的" \n"的位置信息
            struct ContinuousRange {
                // 保存该区间内所有" \n"的匹配索引（在 placeholderMatches 数组中的索引）
                var matchIndices: [Int] = []
                
                // 获取该区间的最后一个匹配索引（正向遍历时的最后一个）
                var lastMatchIndex: Int? {
                    return matchIndices.last
                }
            }
            
            // 识别所有连续出现的" \n"范围
            var continuousRanges: [ContinuousRange] = []
            var currentRange = ContinuousRange()
            
            // " \n" 本身是3个字符（空格+换行符）
            // 如果两个匹配之间间隔不超过1个字符，说明它们是连续的
            for i in 0..<placeholderMatches.count {
                if i == 0 {
                    // 第一个匹配，开始新的区间
                    currentRange.matchIndices.append(i)
                } else {
                    let prevMatch = placeholderMatches[i - 1]
                    let prevEnd = prevMatch.range.location + prevMatch.range.length
                    let currentMatch = placeholderMatches[i]
                    let currentLocation = currentMatch.range.location
                    let gap = currentLocation - prevEnd
                    
                    // 如果间隔不超过1个字符，说明是连续的
                    if gap <= 1 {
                        // 继续当前区间
                        currentRange.matchIndices.append(i)
                    } else {
                        // 不连续，保存当前区间并开始新区间
                        if !currentRange.matchIndices.isEmpty {
                            continuousRanges.append(currentRange)
                        }
                        currentRange = ContinuousRange()
                        currentRange.matchIndices.append(i)
                    }
                }
            }
            
            // 保存最后一个区间
            if !currentRange.matchIndices.isEmpty {
                continuousRanges.append(currentRange)
            }
            
            // 标记需要跳过的匹配索引（每个连续区间的最后一个）
            var skipIndices: Set<Int> = []
            for range in continuousRanges {
                if let lastIndex = range.lastMatchIndex {
                    skipIndices.insert(lastIndex)
                }
            }
            
            // 反向遍历，从后往前替换（跳过标记的匹配）
            for (reversedIndex, match) in placeholderMatches.reversed().enumerated() {
                // 计算正向遍历时的索引
                let originalIndex = placeholderMatches.count - 1 - reversedIndex
                
                // 如果这个匹配不在跳过列表中，则进行替换
                if !skipIndices.contains(originalIndex) {
                    finalMutableString.replaceCharacters(in: match.range, with: placeholder)
                }
            }
            
            let finalProcessed = finalMutableString as String
            LogDebug("final processed: \(finalProcessed)")
            return finalProcessed
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
            
            // 然后重新应用 markdown 解析出的所有样式属性
            // 重要：保留所有 markdown 解析器设置的样式，包括字体、颜色、段落样式等
            attributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
                // 保留所有样式属性
                for (key, value) in attributes {
                    // 对于段落样式，需要合并而不是覆盖
                    if key == .paragraphStyle, let existingParagraphStyle = value as? NSParagraphStyle {
                        // 创建新的段落样式，合并默认样式和 markdown 解析的样式
                        let mergedParagraphStyle = existingParagraphStyle.mutableCopy() as! NSMutableParagraphStyle
                        // 保留 markdown 解析的对齐方式，如果没有则使用默认对齐方式
                        if mergedParagraphStyle.alignment == .natural {
                            mergedParagraphStyle.alignment = textAlignment
                        }
                        // 保留 markdown 解析的行间距，如果没有则使用默认行间距
                        if mergedParagraphStyle.lineSpacing == 0 {
                            mergedParagraphStyle.lineSpacing = 2.0
                        }
                        // 保留 markdown 解析的段落间距，如果没有则使用默认段落间距
                        if mergedParagraphStyle.paragraphSpacing == 0 {
                            mergedParagraphStyle.paragraphSpacing = 4.0
                        }
                        mutableAttributedString.addAttribute(.paragraphStyle, value: mergedParagraphStyle, range: range)
                    } else {
                        // 对于其他属性，直接应用
                        mutableAttributedString.addAttribute(key, value: value, range: range)
                        mutableAttributedString.addAttribute(.foregroundColor, value: defaultColor, range: range)
                    }
                }
            }
            
            // 只对没有段落样式的文本范围应用默认段落样式
            // 遍历文本，找到没有段落样式的范围
            var location = 0
            while location < mutableAttributedString.length {
                var effectiveRange = NSRange()
                let existingParagraphStyle = mutableAttributedString.attribute(.paragraphStyle, at: location, effectiveRange: &effectiveRange) as? NSParagraphStyle
                
                if existingParagraphStyle == nil {
                    // 这个范围没有段落样式，应用默认段落样式
                    mutableAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: effectiveRange)
                    mutableAttributedString.addAttribute(.foregroundColor, value: defaultColor, range: effectiveRange)
                }
                
                location = effectiveRange.location + effectiveRange.length
            }
            
            // 处理占位字符串：将所有 PlaceString 的颜色设置为透明，并为每个占位字符串创建独立段落
            let placeholder = UILabel.PlaceStringWord
            let fullText = mutableAttributedString.string
            var searchRange = NSRange(location: 0, length: fullText.count)
            var placeholderRanges: [NSRange] = []
            
            // 第一步：收集所有占位字符串的位置
            while searchRange.location < fullText.count {
                let foundRange = (fullText as NSString).range(of: placeholder, options: [], range: searchRange)
                if foundRange.location != NSNotFound {
                    placeholderRanges.append(foundRange)
                    // 继续搜索下一个占位字符串
                    let nextLocation = foundRange.location + foundRange.length
                    searchRange = NSRange(location: nextLocation, length: fullText.count - nextLocation)
                } else {
                    // 没有找到更多占位字符串，退出循环
                    break
                }
            }
            let nWord = "\n"
            // 第二步：从后往前处理每个占位字符串，避免索引变化问题
            for foundRange in placeholderRanges.reversed() {
                // 将占位字符串的颜色设置为透明
                mutableAttributedString.addAttribute(.foregroundColor, value: Color.clear, range: foundRange)
                
                // 为每个占位字符串创建独立的段落样式
                // 创建一个新的段落样式，确保占位字符串单独成为一个段落
                let placeholderParagraphStyle = NSMutableParagraphStyle()
                placeholderParagraphStyle.alignment = textAlignment
                placeholderParagraphStyle.lineSpacing = 2.0
                placeholderParagraphStyle.paragraphSpacing = 0.0 // 占位字符串段落不添加额外间距
                placeholderParagraphStyle.paragraphSpacingBefore = 0.0 // 占位字符串段落前不添加额外间距
//                placeholderParagraphStyle.minimumLineHeight = 0.0
//                placeholderParagraphStyle.maximumLineHeight = 0.0
                
                // 将段落样式应用到占位字符串
                mutableAttributedString.addAttribute(.paragraphStyle, value: placeholderParagraphStyle, range: foundRange)
                
                // 确保占位字符串前后都有换行符，使其成为独立段落
                // 获取当前字符串（因为从后往前处理，前面的占位字符串位置还未变化）
                let currentText = mutableAttributedString.string
                let currentNsString = currentText as NSString
                
                // 检查占位字符串前是否有换行符
                if foundRange.location > 0 {
                    let charBefore = currentNsString.character(at: foundRange.location - 1)
                    if charBefore != 0x000A && charBefore != 0x000D { // 不是换行符（\n 或 \r）
                        // 在占位字符串前插入换行符
                        mutableAttributedString.insert(NSAttributedString(string: ""), at: foundRange.location)
                    }
                } else {
                    // 占位字符串在开头，在前面插入换行符
                    mutableAttributedString.insert(NSAttributedString(string: ""), at: 0)
                }
                
                // 检查占位字符串后是否有换行符
                // 注意：由于可能已经在前面的代码中插入了换行符，需要重新计算位置
                let updatedText = mutableAttributedString.string
                let updatedNsString = updatedText as NSString
                // 重新查找占位字符串的位置（因为可能已经插入了换行符）
                // 从原始位置附近开始查找，避免找到其他位置的占位字符串
                let searchStartLocation = max(0, foundRange.location - 1)
                let searchLength = min(updatedNsString.length - searchStartLocation, foundRange.length + 10)
                let updatedSearchRange = NSRange(location: searchStartLocation, length: searchLength)
                let updatedRange = updatedNsString.range(of: placeholder, options: [], range: updatedSearchRange)
                if updatedRange.location != NSNotFound {
                    let endLocation = updatedRange.location + updatedRange.length
                    if endLocation < mutableAttributedString.length {
                        let charAfter = updatedNsString.character(at: endLocation)
                        if charAfter != 0x000A && charAfter != 0x000D { // 不是换行符（\n 或 \r）
                            // 在占位字符串后插入换行符
                            mutableAttributedString.insert(NSAttributedString(string: nWord), at: endLocation)
                        }
                    } else {
                        // 占位字符串在末尾，在后面插入换行符
                        mutableAttributedString.append(NSAttributedString(string: nWord))
                    }
                }
            }
            
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

//
//  UILabel+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/18.
//

import UIKit

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
    
    /// 设置 Markdown 文本（iOS 15+）
    /// - Parameters:
    ///   - markdown: Markdown 格式的字符串
    ///   - options: Markdown 解析选项
    ///   - baseURL: 相对链接的基础 URL
    @available(iOS 15.0, *)
    func setMarkdownText(
        _ markdown: String,
        options: AttributedString.MarkdownParsingOptions = .init(),
        baseURL: URL? = nil
    ) {
        do {
            let attributedString = try NSAttributedString(
                markdown: markdown,
                options: options,
                baseURL: baseURL
            )
            self.attributedText = attributedString
        } catch {
            // 解析失败时显示原始文本
            self.text = markdown
            print("Markdown 解析失败: \(error)")
        }
    }
    
    /// 计算 Markdown 文本的高度
    /// - Parameters:
    ///   - markdown: Markdown 格式的字符串
    ///   - maxWidth: 最大宽度
    ///   - options: Markdown 解析选项
    /// - Returns: 计算出的高度
    @available(iOS 15.0, *)
    func calculateMarkdownHeight(
        markdown: String,
        maxWidth: CGFloat,
        options: AttributedString.MarkdownParsingOptions = .init()
    ) -> CGFloat {
        do {
            let attributedString = try NSAttributedString(
                markdown: markdown,
                options: options
            )
            return calculateAttributedTextSize(maxWidth: maxWidth).height
        } catch {
            // 解析失败时使用普通文本计算
            return calculateSizeWithSizeThatFits(maxWidth: maxWidth).height
        }
    }
}

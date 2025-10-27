//
//  String+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension String {
    var isChineseName: Bool {
        let chineseNameRegex = "^[\u{4e00}-\u{9fa5}]{2,4}$"
        let chineseNamePredicate = NSPredicate(format: "SELF MATCHES %@", chineseNameRegex)
        return chineseNamePredicate.evaluate(with: self)
    }

    var isSixDigitNumber: Bool {
        let sixDigitNumberRegex = "^[0-9]{6}$"
        let sixDigitNumberPredicate = NSPredicate(format: "SELF MATCHES %@", sixDigitNumberRegex)
        return sixDigitNumberPredicate.evaluate(with: self)
    }

    var isPhoneNumber: Bool {
        let phoneNumberRegex = "^1\\d{10}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberPredicate.evaluate(with: self)
    }

    var isIDCardNumber: Bool {
        let idCardRegex = "^(\\d{15})|(\\d{17}([0-9]|X))$"
        let idCardPredicate = NSPredicate(format: "SELF MATCHES %@", idCardRegex)
        return idCardPredicate.evaluate(with: self)
    }

    func isPhoneOrEmail() -> (isValid: Bool, type: String?) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let phoneRegex = "^\\+?[0-9]{10,15}$"

        if self.range(of: emailRegex, options: .regularExpression) != nil {
            return (true, "Email")
        } else if self.range(of: phoneRegex, options: .regularExpression) != nil {
            return (true, "Phone")
        }

        return (false, nil)
    }
}

extension String {
    func appending(_ parameters: [String: Any]?) -> String {
        guard let parameters else {
            return self
        }

        var appendedString = self

        var hasQustionMask = false
        for (key, value) in parameters {
            if hasQustionMask == false {
                appendedString += "?"
            } else {
                appendedString += "&"
            }
            hasQustionMask = true

            if let stringValue = value as? String {
                appendedString += "\(key)=\(stringValue)"
            } else {
                appendedString += "\(key)=\(String(describing: value))"
            }
        }

        return appendedString
    }
}

extension String {
    static func from(_ item: Any?) -> String? {
        return item != nil ? String(describing: item) : nil
    }
}

extension String {
    func convertLineBreaksToHTML() -> String {
        // Replace escaped \n with real \n
        let normalizedText = replacingOccurrences(of: "\\n", with: "\n")
        // Step 1: Replace two or more consecutive line breaks with a placeholder
        let paragraphRegex = try? NSRegularExpression(pattern: "\n{2,}", options: [])
        let placeholder = "___PARA___"
        var html =
            paragraphRegex?.stringByReplacingMatches(
                in: normalizedText,
                options: [],
                range: NSRange(location: 0, length: normalizedText.utf16.count),
                withTemplate: placeholder
            ) ?? normalizedText
        // Step 2: Replace single line breaks with <br>
        let singleLineRegex = try? NSRegularExpression(pattern: "\n", options: [])
        html =
            singleLineRegex?.stringByReplacingMatches(
                in: html,
                options: [],
                range: NSRange(location: 0, length: html.utf16.count),
                withTemplate: "<br>"
            ) ?? html
        // Step 3: Replace placeholder with paragraph gap HTML
        html = html.replacingOccurrences(
            of: placeholder, with: "<br><span class=\"br-gap\"></span><br>")
        return html
    }
}

extension String {

    func formattedDateString() -> String? {
        guard let timestamp = Double(self) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timestamp / 1000)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"

        let formattedString = dateFormatter.string(from: date)

        return formattedString
    }
}

extension String {
    var timestamped: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())
        return "[\(timestamp)] \(self)"
    }
    
    func openLink() {
        if let url = URL(string: self) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    var isEmptyStr: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isNotEmptyStr: Bool {
        return !isEmptyStr
    }
    
    /// 计算文本在指定宽度下的高度
    /// - Parameters:
    ///   - font: 字体
    ///   - maxWidth: 最大宽度
    ///   - options: 文本绘制选项，默认为 [.usesLineFragmentOrigin, .usesFontLeading]
    /// - Returns: 文本高度
    func calculateHeight(
        with font: UIFont,
        maxWidth: CGFloat,
        options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
    ) -> CGFloat {
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: options,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
    
    /// 计算文本在指定宽度下的尺寸
    /// - Parameters:
    ///   - font: 字体
    ///   - maxWidth: 最大宽度
    ///   - options: 文本绘制选项，默认为 [.usesLineFragmentOrigin, .usesFontLeading]
    /// - Returns: 文本尺寸
    func calculateSize(
        with font: UIFont,
        maxWidth: CGFloat,
        options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
    ) -> CGSize {
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: options,
            attributes: [.font: font],
            context: nil
        )
        return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
}

extension String {
    func isSimilarToColor(_ color: String) -> Bool {
        guard let foregroundColor = UIColor(hexString: self),
            let backgroundColor = UIColor(hexString: color)
        else {
            return false
        }

        var foregroundRed: CGFloat = 0
        var foregroundGreen: CGFloat = 0
        var foregroundBlue: CGFloat = 0
        var foregroundAlpha: CGFloat = 0

        var backgroundRed: CGFloat = 0
        var backgroundGreen: CGFloat = 0
        var backgroundBlue: CGFloat = 0
        var backgroundAlpha: CGFloat = 0

        foregroundColor.getRed(
            &foregroundRed, green: &foregroundGreen, blue: &foregroundBlue, alpha: &foregroundAlpha)
        backgroundColor.getRed(
            &backgroundRed, green: &backgroundGreen, blue: &backgroundBlue, alpha: &backgroundAlpha)

        let colorDelta =
            abs(foregroundRed - backgroundRed) + abs(foregroundGreen - backgroundGreen)
            + abs(foregroundBlue - backgroundBlue)

        return colorDelta < 0.5
    }
}

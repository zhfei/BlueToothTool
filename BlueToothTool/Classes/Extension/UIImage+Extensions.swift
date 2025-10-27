//
//  UIImage+Extensions.swift
//  RepReady
//
//  Created by 周飞 on 2025/8/23.
//

import UIKit

extension UIImage {
    /// 给图片添加上下左右的透明内边距
    func withPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> UIImage? {
        let newWidth = size.width + left + right
        let newHeight = size.height + top + bottom
        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let origin = CGPoint(x: left, y: top)
        self.draw(at: origin)
        let paddedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return paddedImage
    }
}

extension UIImage {

    func translate(degrees: CGFloat = -90, scale: CGFloat = 1, x: CGFloat = 0, y: CGFloat = 0)
        -> UIImage
    {

        // Calculate the size of the rotated view's containing box for our drawing space
        let rotatedSize = CGSize(
            width: size.height,
            height: size.width)

        // Make the bitmap context
        UIGraphicsBeginImageContextWithOptions(
            rotatedSize, false, self.scale)

        // Move origin to middle
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: rotatedSize.width / 2 + x, y: rotatedSize.height / 2 + y)

        // Rotate the image context
        context.rotate(by: degrees * .pi / 180)

        context.scaleBy(x: scale, y: scale)

        // Draw the image
        draw(
            in: CGRect(
                x: -size.width / 2,
                y: -size.height / 2,
                width: size.width,
                height: size.height))

        // Get the image from the context and restore
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage!
    }
    
    /// 调整图片尺寸
    /// - Parameter targetSize: 目标尺寸
    /// - Returns: 调整后的图片
    func resizeImage(to targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // 使用较小的比例来确保图片完全适应目标尺寸
        let newSize: CGSize
        if widthRatio < heightRatio {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        } else {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIImage {

    func tintWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.fill(rect)
        self.draw(in: rect, blendMode: .destinationIn, alpha: 1)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.resizableImage(withCapInsets: self.capInsets)
    }

    func blendWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: rect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        context.draw(self.cgImage!, in: rect)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.addRect(rect)
        context.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.resizableImage(withCapInsets: self.capInsets)
    }

    static func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1))
        -> UIImage
    {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    static func avatarImage(
        from text: String, size: CGSize, font: UIFont, fontColor: UIColor, backgroundColor: UIColor
    ) -> UIImage? {
        // 创建一个新的 UIGraphicsImageRenderer 对象
        let renderer = UIGraphicsImageRenderer(size: size)

        // 生成头像图片
        let image = renderer.image { context in
            // 绘制背景颜色
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // 绘制名字首字母或首字
            let attributedText = NSAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: fontColor,
                ])

            // 计算文字的尺寸并居中绘制
            let textSize = attributedText.size()
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            attributedText.draw(in: textRect)
        }

        return image
    }
}

extension UIImage {
    static func gradientShadowImage(
        startColor: UIColor, endColor: UIColor, shadowOffset: CGSize, shadowOpacity: Float,
        shadowRadius: CGFloat
    ) -> UIImage? {
        let gradientHeight = shadowOffset.height + shadowRadius * 2
        let gradientSize = CGSize(width: 1.0, height: gradientHeight)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = CGRect(origin: .zero, size: gradientSize)
        gradientLayer.shadowOffset = shadowOffset
        gradientLayer.shadowOpacity = shadowOpacity
        gradientLayer.shadowRadius = shadowRadius
        gradientLayer.shadowColor = UIColor.black.cgColor

        UIGraphicsBeginImageContextWithOptions(gradientSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        gradientLayer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        return image.resizableImage(
            withCapInsets: UIEdgeInsets(top: gradientHeight - 1, left: 0, bottom: 0, right: 0),
            resizingMode: .tile)
    }
}

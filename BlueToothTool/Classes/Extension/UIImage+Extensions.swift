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

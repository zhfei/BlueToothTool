//
//  UIBezierPath+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension UIBezierPath {
    convenience init(cornersRadius: UICornersRadius, size: CGSize, offsetX: CGFloat) {
        self.init()

        let rect = CGRect(origin: CGPoint(x: offsetX, y: 0), size: size)
        let path = buildPath(rect: rect, cornersRadius: cornersRadius)
        self.append(path)
    }

    func buildPath(rect: CGRect, cornersRadius: UICornersRadius) -> UIBezierPath {
        let path = UIBezierPath()

        let topLeftCenter = CGPoint(
            x: rect.minX + cornersRadius.topLeft, y: rect.minY + cornersRadius.topLeft)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornersRadius.topLeft))
        path.addArc(
            withCenter: topLeftCenter, radius: cornersRadius.topLeft, startAngle: CGFloat.pi,
            endAngle: 3 * CGFloat.pi / 2, clockwise: true)

        let topRightCenter = CGPoint(
            x: rect.maxX - cornersRadius.topRight, y: rect.minY + cornersRadius.topRight)
        path.addLine(to: CGPoint(x: rect.maxX - cornersRadius.topRight, y: rect.minY))
        path.addArc(
            withCenter: topRightCenter, radius: cornersRadius.topRight,
            startAngle: 3 * CGFloat.pi / 2, endAngle: 0, clockwise: true)

        let bottomRightCenter = CGPoint(
            x: rect.maxX - cornersRadius.bottomRight, y: rect.maxY - cornersRadius.bottomRight)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornersRadius.bottomRight))
        path.addArc(
            withCenter: bottomRightCenter, radius: cornersRadius.bottomRight, startAngle: 0,
            endAngle: CGFloat.pi / 2, clockwise: true)

        let bottomLeftCenter = CGPoint(
            x: rect.minX + cornersRadius.bottomLeft, y: rect.maxY - cornersRadius.bottomLeft)
        path.addLine(to: CGPoint(x: rect.minX + cornersRadius.bottomLeft, y: rect.maxY))
        path.addArc(
            withCenter: bottomLeftCenter, radius: cornersRadius.bottomLeft,
            startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)

        path.close()

        return path
    }
}

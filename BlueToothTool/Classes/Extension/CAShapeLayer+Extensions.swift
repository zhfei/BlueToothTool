//
//  CAShapeLayer+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension CAShapeLayer {

    func playTriangleLeftHalfPath() -> CGPath {
        let radius = 1.0
        let offsetX = 1.0  // 修复播放三角形视觉差
        let rect = CGRect(
            x: offsetX, y: -radius / 2, width: bounds.width + radius / 2,
            height: bounds.height + radius + offsetX)
        let point1 = CGPoint(x: offsetX, y: rect.minY)
        let point2 = CGPoint(x: offsetX, y: rect.maxY)
        let point3 = CGPoint(x: bounds.width, y: rect.maxY - bounds.width * atan(CGFloat.pi / 6))
        let point4 = CGPoint(x: bounds.width, y: rect.minY + bounds.width * atan(CGFloat.pi / 6))

        let path = CGMutablePath()
        path.move(to: point4)
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addLine(to: point3)
        path.addLine(to: point4)
        path.addArc(tangent1End: point4, tangent2End: point1, radius: radius)
        path.closeSubpath()

        return path
    }

    func playTriangleRightHalfPath() -> CGPath {
        let radius = 1.0
        let offsetX = 1.0  // 修复播放三角形视觉差
        let rect = CGRect(
            x: 0, y: -radius / 2, width: bounds.width + radius / 2,
            height: bounds.height + radius + offsetX)
        let point1 = CGPoint(x: 0, y: rect.minY + bounds.width * atan(CGFloat.pi / 6))
        let point2 = CGPoint(x: 0, y: rect.maxY - bounds.width * atan(CGFloat.pi / 6))
        let point3 = CGPoint(x: bounds.width + radius, y: rect.minY + rect.height / 2)

        let path = CGMutablePath()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: radius)
        path.closeSubpath()

        return path
    }

    func pauseLineLeftHalfPath() -> CGPath {
        let radius = 1.0
        let lineWidth = 3.0
        let point0 = CGPoint(x: radius, y: 0)
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 0, y: bounds.height)
        let point3 = CGPoint(x: lineWidth, y: bounds.height)
        let point4 = CGPoint(x: lineWidth, y: 0)

        let path = CGMutablePath()

        path.move(to: point0)
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addArc(tangent1End: point3, tangent2End: point4, radius: radius)
        path.addArc(tangent1End: point4, tangent2End: point1, radius: radius)
        path.closeSubpath()

        return path
    }

    func pauseLineRightHalfPath() -> CGPath {
        let radius = 1.0
        let lineWidth = 3.0
        let point1 = CGPoint(x: bounds.width - lineWidth, y: 0)
        let point2 = CGPoint(x: bounds.width - lineWidth, y: bounds.height)
        let point3 = CGPoint(x: bounds.width, y: bounds.height)
        let point4 = CGPoint(x: bounds.width, y: 0)

        let path = CGMutablePath()

        path.move(to: point1)
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addArc(tangent1End: point3, tangent2End: point4, radius: radius)
        path.addArc(tangent1End: point4, tangent2End: point1, radius: radius)
        path.closeSubpath()

        return path
    }
}


//
//  CALayer+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

public struct UICornersRadius: Hashable {
    init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    mutating func flipLeftRight() {
        (topLeft, topRight, bottomLeft, bottomRight) = (topRight, topLeft, bottomRight, bottomLeft)
    }
}

extension CALayer {
    func shapeLayer(with cornersRadius: UICornersRadius) -> CAShapeLayer {
        let topLeftRadius = cornersRadius.topLeft
        let topRightRadius = cornersRadius.topRight
        let bottomLeftRadius = cornersRadius.bottomLeft
        let bottomRightRadius = cornersRadius.bottomRight

        let path = UIBezierPath()

        // Top left corner
        path.move(to: CGPoint(x: 0, y: topLeftRadius))
        path.addArc(
            withCenter: CGPoint(x: topLeftRadius, y: topLeftRadius), radius: topLeftRadius,
            startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true)

        // Top right corner
        path.addLine(to: CGPoint(x: bounds.width - topRightRadius, y: 0))
        path.addArc(
            withCenter: CGPoint(x: bounds.width - topRightRadius, y: topRightRadius),
            radius: topRightRadius, startAngle: CGFloat.pi * 1.5, endAngle: 0, clockwise: true)

        // Bottom right corner
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - bottomRightRadius))
        path.addArc(
            withCenter: CGPoint(
                x: bounds.width - bottomRightRadius, y: bounds.height - bottomRightRadius),
            radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi * 0.5, clockwise: true)

        // Bottom left corner
        path.addLine(to: CGPoint(x: bottomLeftRadius, y: bounds.height))
        path.addArc(
            withCenter: CGPoint(x: bottomLeftRadius, y: bounds.height - bottomLeftRadius),
            radius: bottomLeftRadius, startAngle: CGFloat.pi * 0.5, endAngle: CGFloat.pi,
            clockwise: true)

        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = bounds.center
        shapeLayer.path = path.cgPath

        return shapeLayer
    }

    func set(cornersRadius: UICornersRadius) {
        let shapeLayer = shapeLayer(with: cornersRadius)
        mask = shapeLayer
    }

    func setBorder(cornersRadius: UICornersRadius, borderColor: UIColor, borderWidth: CGFloat) {
        let strokeLayer = shapeLayer(with: cornersRadius)
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.strokeColor = borderColor.cgColor
        strokeLayer.lineWidth = borderWidth

        removeSublayers(ofType: CAShapeLayer.self)

        addSublayer(strokeLayer)
    }
    
    func removeSublayers<T>(ofType type: T.Type) {
        sublayers?.filter {
            $0 is T
        }.forEach {
            $0.removeFromSuperlayer()
        }
    }
}

extension CALayer {

    enum BasicAnimationKeyPath: String {
        case path
        case bounds
        case position
        case colors
    }

    func addAnimation(
        for keyPath: BasicAnimationKeyPath, fromValue: Any?, toValue: Any?, duration: CGFloat = 0.3
    ) {
        let animation = basicAnimation(
            keyPath: keyPath.rawValue, fromValue: fromValue, toValue: toValue, duration: duration)
        add(animation, forKey: keyPath.rawValue)
    }

    func basicAnimation(keyPath: String, fromValue: Any?, toValue: Any?, duration: CGFloat = 0.3)
        -> CABasicAnimation
    {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
}






















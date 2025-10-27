//
//  UIView+Extensions.swift
//  RepReady
//
//  Created by 周飞 on 2025/8/22.
//

import UIKit

extension UIView {
    
    // MARK: - Frame Properties
    
    /// 快速访问和设置 x 坐标
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    /// 快速访问和设置 y 坐标
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    /// 快速访问和设置宽度
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    /// 快速访问和设置高度
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    /// 快速访问和设置 size
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    /// 快速访问和设置 origin
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }
    
    /// 快速访问和设置 centerX
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center.x = newValue
        }
    }
    
    /// 快速访问和设置 centerY
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center.y = newValue
        }
    }
    
    /// 快速访问和设置右边距
    var right: CGFloat {
        get {
            return x + width
        }
        set {
            x = newValue - width
        }
    }
    
    /// 快速访问和设置下边距
    var bottom: CGFloat {
        get {
            return y + height
        }
        set {
            y = newValue - height
        }
    }
    
    // MARK: - Convenience Methods
    
    /// 设置 frame 的所有属性
    func setFrame(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    /// 设置 size
    func setSize(width: CGFloat, height: CGFloat) {
        size = CGSize(width: width, height: height)
    }
    
    /// 设置 origin
    func setOrigin(x: CGFloat, y: CGFloat) {
        origin = CGPoint(x: x, y: y)
    }
    
    /// 设置 center
    func setCenter(x: CGFloat, y: CGFloat) {
        center = CGPoint(x: x, y: y)
    }
}

extension UIView {
    func showToast(
        _ message: String, duration: TimeInterval = ToastManager.shared.duration,
        imageType: Assets.ToastImageType = .none, style: ToastStyle = ToastManager.shared.style
    ) {
        let image: UIImage?
        switch imageType {
        case .none:
            image = nil
        case .completed:
            image = UIImage(named: Assets.ImageName.toastCompleted)
        case .error:
            image = UIImage(named: Assets.ImageName.toastError)
        case .tip:
            image = UIImage(named: Assets.ImageName.toastTip)
        case .custom(let customImage):
            image = customImage
        }
        makeToast(message, duration: duration, image: image, style: style)
    }
}

extension UIView {
    class func viewFromNib<T: UIView>() -> T {
        let nibName = String(describing: T.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? T else {
            fatalError("Could not load view from nib file.")
        }
        return view
    }
}

extension UIView {

    func set(corners: UIRectCorner, radius: CGFloat, size: CGSize) {
        let maskPath = UIBezierPath(
            roundedRect: CGRect(origin: .zero, size: size), byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath

        layer.mask = maskLayer
    }

    func set(corners: UIRectCorner, radius: CGFloat) {
        set(corners: corners, radius: radius, size: bounds.size)
    }

    func setBorder(with color: UIColor, corners: UIRectCorner, radius: CGFloat) {
        setBorder(with: color, corners: corners, radius: radius, size: bounds.size)
    }

    func setBorder(with color: UIColor, corners: UIRectCorner, radius: CGFloat, size: CGSize) {
        let maskPath = UIBezierPath(
            roundedRect: bounds, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))

        let strokeLayer = CAShapeLayer()
        strokeLayer.frame = bounds
        strokeLayer.path = maskPath.cgPath
        strokeLayer.lineWidth = 1
        strokeLayer.strokeColor = color.cgColor
        strokeLayer.fillColor = UIColor.clear.cgColor

        layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }

        layer.addSublayer(strokeLayer)
    }

    func setBorder(edges: UIRectEdge, color: UIColor, width: CGFloat) {
        layer.sublayers?.forEach { layer in
            if layer.name == "RectEdgeLayer" {
                layer.removeFromSuperlayer()
            }
        }

        let borderLayer = CAShapeLayer()
        borderLayer.name = "RectEdgeLayer"
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = width

        let path = UIBezierPath()
        let bounds = self.bounds
        let origin = bounds.origin
        let size = bounds.size

        if edges.contains(.top) {
            path.move(to: origin)
            path.addLine(to: CGPoint(x: origin.x + size.width, y: origin.y))
        }

        if edges.contains(.bottom) {
            path.move(to: CGPoint(x: origin.x, y: origin.y + size.height))
            path.addLine(to: CGPoint(x: origin.x + size.width, y: origin.y + size.height))
        }

        if edges.contains(.left) {
            path.move(to: origin)
            path.addLine(to: CGPoint(x: origin.x, y: origin.y + size.height))
        }

        if edges.contains(.right) {
            path.move(to: CGPoint(x: origin.x + size.width, y: origin.y))
            path.addLine(to: CGPoint(x: origin.x + size.width, y: origin.y + size.height))
        }

        borderLayer.path = path.cgPath
        layer.addSublayer(borderLayer)
    }

    func setArch(corners: UIRectCorner, radius: CGFloat) {

        let bounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + 100)
        let maskPath = UIBezierPath(rect: bounds)

        let archRect = CGRect(
            x: 0, y: bounds.height - radius - 100, width: bounds.width, height: radius * 2 + 100)
        let archPath = UIBezierPath(
            roundedRect: archRect, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))

        maskPath.append(archPath)
        maskPath.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = .evenOdd

        layer.mask = maskLayer
    }
}

extension UIView {
    func toImage() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}

extension UIView {
    func addGradientBorder(
        colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, borderWidth: CGFloat,
        cornerRadius: CGFloat
    ) {
        let oldGradientLayer =
            layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer

        let oldCGColors = oldGradientLayer?.colors as? [CGColor]
        let newCGColors = colors.map { $0.cgColor }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = newCGColors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds

        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath(
            roundedRect: gradientLayer.bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2),
            cornerRadius: cornerRadius)
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = borderWidth

        gradientLayer.addAnimation(
            for: .colors, fromValue: oldCGColors, toValue: newCGColors, duration: 0.3)
        gradientLayer.mask = shapeLayer

        layer.removeSublayers(ofType: CAGradientLayer.self)
        layer.addSublayer(gradientLayer)
    }
}

extension UIView {
    func setVerticalGradientBackground(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        layer.insertSublayer(gradientLayer, at: 0)
    }

    func setHorizontalGradientBackground(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        layer.insertSublayer(gradientLayer, at: 0)
    }

    func setDiagonalTopLeftToBottomRightGradientBackground(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        layer.insertSublayer(gradientLayer, at: 0)
    }

    func setDiagonalTopRightToBottomLeftGradientBackground(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)

        layer.insertSublayer(gradientLayer, at: 0)
    }
}


extension UIView {
    func findFirstSubview<T: UIView>(ofType type: T.Type) -> T? {
        for subview in subviews {
            if let typedSubview = subview as? T {
                return typedSubview
            } else if let typedSubview = subview.findFirstSubview(ofType: type) {
                return typedSubview
            }
        }
        return nil
    }
}


//!!!: 动画
extension UIView {

    func startRotationAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0)
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = .infinity

        layer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    func stopRotationAnimation() {
        layer.removeAnimation(forKey: "rotationAnimation")
    }
}

extension UIView {
    private static let breathAnimationKey = "breathAnimation"

    func startBreathingAnimation(scaled scale: CGFloat = 1.0, speed: CGFloat = 1.0) {
        guard speed >= 0.1 else {
            return
        }
        let breathAnimation = CABasicAnimation(keyPath: "transform.scale")
        breathAnimation.duration = 1 / speed
        breathAnimation.autoreverses = true
        breathAnimation.repeatCount = Float.infinity
        breathAnimation.fromValue = 1.0
        breathAnimation.toValue = scale
        breathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.add(breathAnimation, forKey: UIView.breathAnimationKey)
    }

    func stopBreathingAnimation() {
        layer.removeAnimation(forKey: UIView.breathAnimationKey)
    }
}


extension UIView {
    func moveToFront() {
        self.superview?.bringSubviewToFront(self)
    }

    func moveToBack() {
        self.superview?.sendSubviewToBack(self)
    }
}



extension UIView {
    private struct AssociatedKeys {
        static var highlightedColor = "highlightedColor"
        static var backgroundLayer = "backgroundLayer"
        static var highlightedEdgeInsets = "highlightedEdgeInsets"
    }

    var highlightedColor: UIColor? {
        get {
            let key = UnsafePointer(&AssociatedKeys.highlightedColor)
            return objc_getAssociatedObject(self, key) as? UIColor
        }
        set {
            let key = UnsafePointer(&AssociatedKeys.highlightedColor)
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var highlightedEdgeInsets: UIEdgeInsets {
        get {
            let key = UnsafePointer(&AssociatedKeys.highlightedEdgeInsets)
            return objc_getAssociatedObject(self, key) as? UIEdgeInsets ?? .zero
        }
        set {
            let key = UnsafePointer(&AssociatedKeys.highlightedEdgeInsets)
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var backgroundLayer: CALayer? {
        get {
            let key = UnsafePointer(&AssociatedKeys.backgroundLayer)
            return objc_getAssociatedObject(self, key) as? CALayer
        }
        set {
            let key = UnsafePointer(&AssociatedKeys.backgroundLayer)
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let highlightedColor = highlightedColor else { return }

        if backgroundLayer == nil {
            let bgLayer = CALayer()
            bgLayer.frame = expandedFrame
            bgLayer.backgroundColor = highlightedColor.cgColor
            bgLayer.opacity = 0
            bgLayer.cornerRadius = layer.cornerRadius
            layer.insertSublayer(bgLayer, at: 0)
            backgroundLayer = bgLayer
        }

        animateBackgroundLayerOpacity(to: 1)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateBackgroundLayerOpacity(to: 0)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateBackgroundLayerOpacity(to: 0)
    }

    private func animateBackgroundLayerOpacity(to opacity: Float) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer?.opacity = opacity
        CATransaction.commit()

        if opacity == 0 {
            backgroundLayer?.removeFromSuperlayer()
            backgroundLayer = nil
        }
    }

    private var expandedFrame: CGRect {
        return CGRect(
            x: 0 - highlightedEdgeInsets.left,
            y: 0 - highlightedEdgeInsets.top,
            width: frame.size.width + highlightedEdgeInsets.left + highlightedEdgeInsets.right,
            height: frame.size.height + highlightedEdgeInsets.top + highlightedEdgeInsets.bottom)
    }

    func setHighlightedColor(
        _ highlightedColor: UIColor,
        with highlightedEdgeInsets: UIEdgeInsets = UIEdgeInsets(
            top: 0, left: 0, bottom: 0, right: 0), cornerRadius: CGFloat = 6.0
    ) {
        self.highlightedColor = highlightedColor
        self.highlightedEdgeInsets = highlightedEdgeInsets
        layer.cornerRadius = cornerRadius
        backgroundLayer?.cornerRadius = cornerRadius
    }
}






extension UIView {
    
    /// Performs a playful, "cute" bounce animation on the view.
    ///
    /// This animation uses keyframes to scale the view up with a slight rotation,
    /// then scales it down with an opposite rotation, before settling back to its original state.
    /// - Parameters:
    ///   - duration: The total duration of the animation.
    ///   - completion: A closure to be executed when the animation sequence ends.
    func performCuteBounceAnimation(duration: TimeInterval = 0.8, completion: ((Bool) -> Void)? = nil) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            // Keyframe 1: Big scale up and rotate right
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4).rotated(by: .pi / 20)
            }
            // Keyframe 2: Bounce back (scale down) and rotate left
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).rotated(by: -.pi / 20)
            }
            // Keyframe 3: Smaller secondary bounce
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1).rotated(by: .pi / 30)
            }
            // Keyframe 4: Settle back to original state
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.transform = .identity
            }
        }, completion: completion)
    }
}

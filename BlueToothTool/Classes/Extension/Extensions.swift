//
//  Extensions.swift
//  JingChat
//
//  Created by Jim Learning on 2023/5/31.
//

import SwifterSwift
import UIKit

let Debug: Bool = {
    let Debug: Bool
    #if DEBUG
        Debug = true
    #else
        Debug = false
    #endif
    return Debug
}()

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

func printWithTimestamp(_ message: String, functionName: String = #function) {
    guard Debug else {
        return
    }
    let timestampedMessage = "\(functionName): \(message)".timestamped
    print(timestampedMessage)
}

extension DispatchQueue {
    public static func asyncInMainQueue(_ workItem: @escaping () -> Void) {
        if DispatchQueue.isMainQueue {
            workItem()
        } else {
            DispatchQueue.main.async(execute: workItem)
        }
    }
}

func configure<T: AnyObject>(_ object: T, closure: (T) -> Void) -> T {
    closure(object)
    return object
}

extension Dictionary where Key == String, Value == Any {
    /**
     * 将一个 [String: Any] 类型的字典安全地转换为一个指定的 Codable 模型。
     *
     * - Parameter type: 要转换成的目标模型的类型 (例如 `User.self`)。
     * - Returns: 一个可选的、转换后的模型实例。如果转换失败，则返回 `nil`。
     *
     * 该方法是通用的，适用于任何遵循 `Decodable` 协议的 struct 或 class。
     */
    func toModel<T: Decodable>(
        _ type: T.Type, strategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            print("❌ Error: Could not serialize dictionary to Data.")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = strategy
        guard let model = try? decoder.decode(T.self, from: data) else {
            print("❌ Error: Could not decode Data to model of type \(T.self).")
            print("   - Check if all required properties of \(T.self) exist in the dictionary.")
            print("   - Check if data types match the model's properties.")
            return nil
        }

        return model
    }
}

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
    var viewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }

    func moveToFront() {
        self.superview?.bringSubviewToFront(self)
    }

    func moveToBack() {
        self.superview?.sendSubviewToBack(self)
    }
}

extension UIViewController {
    var fullNavigationBarHeight: CGFloat {
        guard let topInset = view.window?.safeAreaInsets.top else {
            return 0
        }
        let navigationBarHeight = topInset + (navigationController?.navigationBar.frame.height ?? 0)
        return navigationBarHeight
    }
}

extension UIViewController {
    func push<T: UIViewController>(page ViewController: T.Type) {
        let viewController = ViewController.init()
        navigationController?.pushViewController(viewController, animated: true)
    }

    func push(page viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func present<T: UIViewController>(page ViewController: T.Type) {
        let viewController = ViewController.init()
        present(viewController, animated: true)
    }

    func present(page viewController: UIViewController) {
        present(viewController, animated: true)
    }

    static func push(by viewController: UIViewController) {
        let newViewController = Self.init()
        viewController.navigationController?.pushViewController(newViewController, animated: true)
    }

    static func present(by viewController: UIViewController) {
        let newViewController = Self.init()
        viewController.present(newViewController, animated: true)
    }
}

extension NSDirectionalEdgeInsets {
    init(_ edgeInsets: UIEdgeInsets) {
        self = NSDirectionalEdgeInsets(
            top: edgeInsets.top,
            leading: edgeInsets.left,
            bottom: edgeInsets.bottom,
            trailing: edgeInsets.right)
    }

    init(edgeInset: CGFloat) {
        self = NSDirectionalEdgeInsets(
            top: edgeInset,
            leading: edgeInset,
            bottom: edgeInset,
            trailing: edgeInset)
    }
}

extension UIEdgeInsets {
    init(_ edgeInsets: NSDirectionalEdgeInsets) {
        self = UIEdgeInsets(
            top: edgeInsets.top,
            left: edgeInsets.leading,
            bottom: edgeInsets.bottom,
            right: edgeInsets.trailing)
    }

    init(subtractive edgeInsets: NSDirectionalEdgeInsets) {
        self = UIEdgeInsets(
            top: -edgeInsets.top,
            left: -edgeInsets.leading,
            bottom: -edgeInsets.bottom,
            right: -edgeInsets.trailing)
    }

    init(edge: CGFloat) {
        self = UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
    }
}

extension Int {

    var hourToSecondDescription: String {
        if self > 3600 {
            let hours = self / 3600
            let minutes = (self % 3600) / 60
            let seconds = (self % 3600) % 60

            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            let minutes = self / 60
            let seconds = self % 60

            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

func showToast(
    _ message: String,
    duration: TimeInterval = ToastManager.shared.duration,
    imageType: Assets.ToastImageType = .none,
    style: ToastStyle = ToastManager.shared.style
) {
    UIApplication.topMostViewController()?.showToast(
        message,
        duration: duration,
        imageType: imageType,
        style: style)
}

extension UIViewController {
    func showAlert(
        title: String? = nil,
        message: String? = nil,
        confirmTitle: String = "确认",
        confirmStyle: UIAlertAction.Style = .destructive,
        confirmAction: @escaping () -> Void
    ) {
        let alertController = UIAlertController(
            title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: confirmTitle, style: confirmStyle) { (_) in
            confirmAction()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    func showActivity() {
        view.makeToastActivity(view.center)
    }
    func hideActivity() {
        view.hideToastActivity()
    }
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
        view.makeToast(message, duration: duration, image: image, style: style)
    }
    func hideToast() {
        view.hideToast()
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

extension UITableView {
    func register<T: UITableViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: name))
    }

    func register<T: UITableViewCell>(nib: UINib?, withCellClass name: T.Type) {
        register(nib, forCellReuseIdentifier: String(describing: name))
    }

    func register<T: UITableViewCell>(
        nibWithCellClass name: T.Type, at bundleClass: AnyClass? = nil
    ) {
        let identifier = String(describing: name)
        var bundle: Bundle?

        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }

        register(UINib(nibName: identifier, bundle: bundle), forCellReuseIdentifier: identifier)
    }

    func reusableCell<T: UITableViewCell>(from cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard
            let cell = dequeueReusableCell(
                withIdentifier: String(describing: cellClass), for: indexPath) as? T
        else {
            fatalError("Unable to dequeue cell with identifier: \(String(describing: cellClass))")
        }
        return cell
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(nib: UINib?, forCellWithClass name: T.Type) {
        register(nib, forCellWithReuseIdentifier: String(describing: name))
    }

    func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: name))
    }

    func register<T: UICollectionReusableView>(
        nib: UINib?, forSupplementaryViewOfKind kind: String,
        withClass name: T.Type
    ) {
        register(
            nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: name))
    }

    func register<T: UICollectionViewCell>(
        nibWithCellClass name: T.Type, at bundleClass: AnyClass? = nil
    ) {
        let identifier = String(describing: name)
        var bundle: Bundle?

        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }

        register(UINib(nibName: identifier, bundle: bundle), forCellWithReuseIdentifier: identifier)
    }

    func register<T: UICollectionReusableView>(
        nibWithViewClass name: T.Type, at bundleClass: AnyClass? = nil,
        forSupplementaryViewOfKind kind: String
    ) {
        let identifier = String(describing: name)
        var bundle: Bundle?
        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }
        register(
            UINib(nibName: identifier, bundle: bundle), forSupplementaryViewOfKind: kind,
            withReuseIdentifier: identifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard
            let cell = dequeueReusableCell(
                withReuseIdentifier: String(describing: T.self), for: indexPath) as? T
        else {
            fatalError("Unable to dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }

    func allIndexPaths() -> [IndexPath] {
        var allIndexPaths: [IndexPath] = []

        for section in 0..<numberOfSections {
            for item in 0..<numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                allIndexPaths.append(indexPath)
            }
        }

        return allIndexPaths
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
}

extension CALayer {
    func removeSublayers<T>(ofType type: T.Type) {
        sublayers?.filter {
            $0 is T
        }.forEach {
            $0.removeFromSuperlayer()
        }
    }
}

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

extension UIColor {

    static func color(rgb: Int) -> UIColor {
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0xFF00) >> 8) / 255.0, blue: CGFloat((rgb & 0xFF)) / 255.0,
            alpha: 1.0)
    }

    func blendWithColor(_ color: UIColor) -> UIColor {
        var r1: CGFloat = 0
        var r2: CGFloat = 0
        var g1: CGFloat = 0
        var g2: CGFloat = 0
        var b1: CGFloat = 0
        var b2: CGFloat = 0
        var a1: CGFloat = 0
        var a2: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let alpha = a2
        let beta = 1 - alpha
        let r = r1 * beta + r2 * alpha
        let g = g1 * beta + g2 * alpha
        let b = b1 * beta + b2 * alpha
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

extension CALayer {
    @objc var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: self.borderColor ?? UIColor.clear.cgColor)
        }
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

extension NSObject {

    var safeAreaInsetsTop: CGFloat {
        return UIApplication.shared.currentWindow?.safeAreaInsets.top ?? 0
    }

    var safeAreaInsetsBottom: CGFloat {
        return UIApplication.shared.currentWindow?.safeAreaInsets.bottom ?? 0
    }

    var statusBarHeight: CGFloat {
        let statusBarHeight =
            UIApplication.shared.currentWindow?.windowScene?.statusBarManager?.statusBarFrame.height
            ?? 0
        return statusBarHeight
    }
}

extension UIApplication {
    var currentWindow: UIWindow? {
        return
            connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })
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
    func pinToAllEdges() {
        guard let superview = self.superview else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ])
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

extension UIButton {

    func setTitleWithoutFlashing(_ title: String?, for state: UIControl.State) {
        UIView.performWithoutAnimation {
            setTitle(title, for: state)
            layoutIfNeeded()
        }
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: state)
    }
}

extension UIButton {
    func addHitTestEdgeInsets(_ insets: UIEdgeInsets) {
        let hitRect = bounds.inset(by: insets)
        let hitView = UIButtonExtensionHitView(frame: hitRect)
        addSubview(hitView)
    }

    private class UIButtonExtensionHitView: UIView {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return true
        }
    }
}

extension UIButton {
    func setImageWithHighlightedTint(_ image: UIImage?) {
        setImage(image, for: .normal)
        setImage(image?.tintWithColor(Color.grayLightText), for: .highlighted)
    }
}

let PrimaryGradientLayerName = "PrimaryGradientLayer"

extension UIView {
    func primaryGradientLayer() -> CALayer {
        let layer = CAGradientLayer()
        layer.name = PrimaryGradientLayerName
        layer.colors = [
            UIColor(red: 0.04, green: 0.43, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.02, green: 0.06, blue: 0.96, alpha: 0.5).cgColor,
        ]
        layer.locations = [0, 1]
        layer.frame = bounds
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        return layer
    }
    func refreshPrimaryGradientLayer() {
        let newLayer = primaryGradientLayer()
        if let oldLayer = layer.sublayers?.filter({ $0.isPrimaryGradientLayer() }).first {
            layer.replaceSublayer(oldLayer, with: newLayer)
        } else {
            layer.addSublayer(newLayer)
        }
    }
}

extension CALayer {
    func isPrimaryGradientLayer() -> Bool {
        return name == PrimaryGradientLayerName
    }
}

extension Date {
    func lastYear() -> Date {
        return Calendar.current.date(byAdding: .year, value: -1, to: self)!
    }

    func nextYear() -> Date {
        return Calendar.current.date(byAdding: .year, value: 1, to: self)!
    }

    func lastMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }

    func nextMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    static func dateWithYear(_ year: Int, month: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1  // 默认为每月的第一天
        return calendar.date(from: dateComponents)
    }

    func startAndEndTimestampOfMonth() -> (start: Int64, end: Int64) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let firstDayOfMonth = calendar.date(from: components)!

        var startOfDay = calendar.startOfDay(for: firstDayOfMonth)
        startOfDay.addTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT()))
        let endOfDay = startOfDay.addingTimeInterval(
            86400 * Double(calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 0)
                - 0.001)

        return (Int64(startOfDay.timeIntervalSince1970), Int64(endOfDay.timeIntervalSince1970))
    }

    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format

        return dateFormatter.string(from: self)
    }

    static func fromTimestamp(_ timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    func monthDayHourMinuteDescription() -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)

        return "\(month)/\(day) \(hour):\(minute)"
    }

    func remainingTimeSeconds(until endTimeString: String?) -> Double? {
        guard let endTimeString else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let endTime = dateFormatter.date(from: endTimeString) else {
            return nil
        }

        let timeInterval = endTime.timeIntervalSince(self)
        return timeInterval
    }
}

extension Double {

    func remainingTime() -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = Int(self) / 3600
        let minutes = (Int(self) / 60) % 60
        let seconds = Int(self) % 60
        return (hours: hours, minutes: minutes, seconds: seconds)
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

//extension Array {
//    subscript(safe index: Index) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}

extension Array {
    func randomElements(_ n: Int) -> [Element] {
        var elements = self
        var result = [Element]()
        for _ in 0..<Swift.min(n, elements.count) {
            let index = Int(arc4random_uniform(UInt32(elements.count)))
            result.append(elements[index])
            elements.remove(at: index)
        }
        return result
    }

    func firstN(_ n: Int) -> Self {
        return Array(prefix(n))
    }
}

extension Optional where Wrapped == Any {
    func toString() -> String {
        if let value = self {
            return String(describing: value)
        } else {
            return ""
        }
    }
}

extension DispatchQueue {
    func asyncAfter(delay: Double, execute closure: @escaping () -> Void) {
        self.asyncAfter(deadline: .now() + delay, execute: closure)
    }

    static func runOnMainQueue(_ closure: @escaping () -> Void) {
        if DispatchQueue.isMainQueue {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
}

func keyWindow() -> UIWindow? {
    var keyWindow: UIWindow? = nil
    if let windowScene = UIApplication.shared.connectedScenes.first(where: {
        $0.activationState == .foregroundActive
    }) as? UIWindowScene {
        keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
    }
    return keyWindow
}

/// Make your `UITableViewCell` and `UICollectionViewCell` subclasses
/// conform to this protocol to be able to dequeue them in a type-safe manner
protocol Reusable: AnyObject {
    /// The reuse identifier to use when registering and later dequeuing a reusable cell
    static var reuseIdentifier: String { get }
}

// MARK: - Default implementation

extension Reusable {
    /// By default, use the name of the class as String for its reuseIdentifier
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: Protocol Definition

/// Make your UIView subclasses conform to this protocol when:
/// * they *are* NIB-based, and
/// * this class is used as the XIB's root view
/// *
/// * to be able to instantiate them from the NIB in a type-safe manner
protocol NibLoadable: AnyObject {
    /// The nib file to use to load a new instance of the View designed in a XIB
    static var nib: UINib { get }
}

// MARK: Default implementation

extension NibLoadable {
    /* By default, use the nib which have the same name as the name of the class,
         and located in the bundle of that class */
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension UINib {

    static func loadNibIfExists(for cellClass: AnyClass) -> UINib? {
        let nibName = String(describing: cellClass)
        guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
            return nil
        }
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib
    }
}

extension Dictionary {
    mutating func merge(_ other: [Key: Value]) {
        for (key, value) in other {
            self[key] = value
        }
    }
}

extension String {
    static func * (lhs: String, rhs: Int) -> String {
        return (0..<rhs).reduce("") { result, _ in
            return result + lhs
        }
    }
}

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

extension UIApplication {
    var hasNotch: Bool {
        if let window = UIApplication.shared.currentWindow {
            return window.safeAreaInsets.top > 20  // Adjust this value based on the actual notch height
        }
        return false
    }
}

extension Dictionary {
    func string(for key: Key) -> String? {
        if let value = self[key] as? String {
            return value
        }
        return nil
    }
    func bool(for key: Key) -> Bool? {
        if let value = self[key] as? Bool {
            return value
        }
        return false
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

extension UIColor {
    func isDark() -> Bool {
        guard let components = cgColor.components else { return false }
        let redBrightness = components[0] * 299
        let greenBrightness = components[1] * 587
        let blueBrightness = components[2] * 114
        let brightness = (redBrightness + greenBrightness + blueBrightness) / 1000
        return brightness < 0.5
    }

    static func readableColor(for color: UIColor) -> UIColor {
        if color.isDark() {
            return Color.whiteText
        } else {
            return Color.primaryText
        }
    }

    static func randomColor() -> UIColor {
        return UIColor(hexString: UIColor.randomColorHex()) ?? UIColor.red
    }

    static func randomColorHex() -> String {
        let r = CGFloat.random(in: 0...1)
        let g = CGFloat.random(in: 0...1)
        let b = CGFloat.random(in: 0...1)

        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)

        let hex = String(format: "%02X%02X%02X", red, green, blue)

        return hex
    }

    static func generateContrastingColorHexs() -> (String, String) {
        let foregroundColor = randomColorHex()
        var backgroundColor = randomColorHex()

        // 确保前景色和背景色对比明显
        while foregroundColor.isSimilarToColor(backgroundColor) {
            backgroundColor = randomColorHex()
        }

        return (foregroundColor, backgroundColor)
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

extension NSCollectionLayoutGroup {
    class func vertical(
        layoutSize: NSCollectionLayoutSize, batchSubitem subitem: NSCollectionLayoutItem, count: Int
    ) -> Self {
        if #available(iOS 16.0, *) {
            return self.vertical(layoutSize: layoutSize, repeatingSubitem: subitem, count: count)
        } else {
            return self.vertical(layoutSize: layoutSize, subitem: subitem, count: count)
        }
    }

    class func horizontal(
        layoutSize: NSCollectionLayoutSize, batchSubitem subitem: NSCollectionLayoutItem, count: Int
    ) -> Self {
        if #available(iOS 16.0, *) {
            return self.horizontal(layoutSize: layoutSize, repeatingSubitem: subitem, count: count)
        } else {
            return self.horizontal(layoutSize: layoutSize, subitem: subitem, count: count)
        }
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

extension Array where Element == UInt8 {
    @inlinable
    init(reserveCapacity: Int) {
        self = [Element]()
        self.reserveCapacity(reserveCapacity)
    }

    public init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }

    public func toHexString() -> String {
        `lazy`.reduce(into: "") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            $0 += s
        }
    }
}

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

extension Array where Element == Int {

    func nearestExisting(before element: Element) -> Element? {
        var nearestExistingElement: Element? = nil
        for item in self {
            if item < element {
                nearestExistingElement = item
            } else {
                break
            }
        }
        return nearestExistingElement
    }

    func nearestExisting(after element: Element) -> Element? {
        var nearestExistingElement: Element? = nil
        for item in self {
            if item > element {
                nearestExistingElement = item
                break
            }
        }
        return nearestExistingElement
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

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

extension Optional where Wrapped == Int {
    func toString() -> String? {
        guard let value = self else {
            return nil
        }
        return String(value)
    }
}

extension Optional where Wrapped == String {
    func toInt() -> Int? {
        guard let value = self else {
            return nil
        }
        return Int(value)
    }
}

extension Double {
    func toString(decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }

    var removeTrailingZeros: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16  // 根据需求设置合适的最大小数位数
        formatter.numberStyle = .decimal

        if let result = formatter.string(from: self as NSNumber) {
            return result
        } else {
            return String(self)
        }
    }
}

extension String {
    static func from(_ item: Any?) -> String? {
        return item != nil ? String(describing: item) : nil
    }
}

extension UIViewController {
    func replace(with viewController: UIViewController) {
        guard let navigationController = self.navigationController else {
            return
        }

        var viewControllers = navigationController.viewControllers.filter { $0 != self }
        viewControllers.append(viewController)
        navigationController.setViewControllers(viewControllers, animated: true)
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

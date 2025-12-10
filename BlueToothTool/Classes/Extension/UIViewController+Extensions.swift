//
//  UIViewControllerExtensions.swift
//  RepReady
//
//  Created by Jim Learning on 2025/6/20.
//

import UIKit

public
extension UIViewController {
    //关闭右滑手势（禁止右滑关闭 navigationController 子页面）
    
    // 使用关联对象存储每个视图控制器的状态
    private struct AssociatedKeys {
        static var isSwipeBackGestureDisabled = "isSwipeBackGestureDisabled"
    }
    
    private var isSwipeBackGestureDisabled: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isSwipeBackGestureDisabled) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isSwipeBackGestureDisabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 禁用右滑返回手势（最有效的方法）
    public func closeSwipeBackGesture() {
        // 设置当前视图控制器禁用手势
        isSwipeBackGestureDisabled = true
        
        // 兼容 FDFullscreenPopGesture
        if responds(to: NSSelectorFromString("fd_interactivePopDisabled")) {
            setValue(true, forKey: "fd_interactivePopDisabled")
        }
        
        // 设置手势代理为当前视图控制器
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 确保手势识别器是启用的，但通过代理控制
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    /// 启用右滑返回手势
    public func openSwipeBackGesture() {
        // 设置当前视图控制器启用手势
        isSwipeBackGestureDisabled = false
        
        // 兼容 FDFullscreenPopGesture
        if responds(to: NSSelectorFromString("fd_interactivePopDisabled")) {
            setValue(false, forKey: "fd_interactivePopDisabled")
        }
        
        // 恢复默认的手势代理
        navigationController?.interactivePopGestureRecognizer?.delegate = navigationController as? UIGestureRecognizerDelegate
    }
    
    /// 在viewWillAppear中调用，确保手势状态正确
    public func setupSwipeBackGesture() {
        if isSwipeBackGestureDisabled {
            closeSwipeBackGesture()
        } else {
            openSwipeBackGesture()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension UIViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 检查是否是右滑返回手势
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            // 如果当前视图控制器禁用了手势，返回false
            return !isSwipeBackGestureDisabled
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 允许与其他手势同时识别，避免与IQKeyboardManager冲突
        return true
    }
}

//!!!: Toast
public
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

extension UIViewController {
    var navigationBarAndStateBarHeight: CGFloat {
        guard let topInset = view.window?.safeAreaInsets.top else {
            return 0
        }
        let navigationBarHeight = topInset + (navigationController?.navigationBar.frame.height ?? 0)
        return navigationBarHeight
    }
}

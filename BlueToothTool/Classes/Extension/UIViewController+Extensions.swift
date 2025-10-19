//
//  UIViewControllerExtensions.swift
//  RepReady
//
//  Created by Jim Learning on 2025/6/20.
//

import UIKit

extension UIViewController {
    
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
    
    func presentFullScreen(page viewController: UIViewController) {
        guard let topMostViewController = UIApplication.topMostViewController() else {
            return
        }
        
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        
        topMostViewController.present(viewController, animated: true)
    }
    
    func close() {
        if let navigationController = self as? UINavigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

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

extension UIApplication {
    class func newKeyWindow() -> UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowScene = scene as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window
    }
    
    class func topMostViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowScene = scene as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        let topViewController = window.rootViewController
        return topViewController?.topMostViewController()
    }
}



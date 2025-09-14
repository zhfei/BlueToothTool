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

extension UIView {
    func push<T: UIViewController>(page ViewController: T.Type) {
        let viewController = ViewController.init()
        UIApplication.topMostViewController()?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func push(page viewController: UIViewController) {
        UIApplication.topMostViewController()?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present<T: UIViewController>(page ViewController: T.Type, fullScreen: Bool = false) {
        let viewController = ViewController.init()
        if fullScreen {
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .crossDissolve
        }
        UIApplication.topMostViewController()?.present(viewController, animated: true)
    }
    
    func present(page viewController: UIViewController, fullScreen: Bool = false) {
        if fullScreen {
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .crossDissolve
        }
        UIApplication.topMostViewController()?.present(viewController, animated: true)
    }
}


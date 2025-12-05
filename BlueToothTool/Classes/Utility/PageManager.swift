//
//  ViewUtils.swift
//  RepReady
//
//  Created by zhoufei on 2025/6/26.
//

import UIKit

class PageManager {

    /// 获取当前顶层视图控制器
    /// - Returns: 当前显示的顶层视图控制器
    static func getTopViewController() -> UIViewController? {
        // 使用更现代的API获取keyWindow
        let keyWindow: UIWindow?

        if #available(iOS 15.0, *) {
            // iOS 15及以上版本
            keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            // iOS 15以下版本
            keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }

        guard let window = keyWindow else { return nil }

        var topController = window.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }

        // 如果是导航控制器，返回最顶层的视图控制器
        if let navigationController = topController as? UINavigationController {
            return navigationController.topViewController
        }
        
        // 如果是MainTabViewController类型，则取当前选中的VC
        if let mainTabVC = topController as? UITabBarController {
            if let selectedViewController = mainTabVC.selectedViewController {
                // 如果选中的是导航控制器，返回其顶层视图控制器
                if let selectedNavController = selectedViewController as? UINavigationController {
                    return selectedNavController.topViewController
                }
                // 否则直接返回选中的视图控制器
                return selectedViewController
            }
        }

        return topController
    }

    /// 返回到NavigationController中指定索引的页面
    /// - Parameters:
    ///   - index: 目标页面的索引，0表示根视图控制器
    ///   - animated: 是否使用动画效果，默认为true
    /// - Returns: 是否成功返回到指定页面
    @discardableResult
    static func popToViewController(at index: Int, animated: Bool = true) -> Bool {
        guard let topVC = getTopViewController() else { return false }

        // 获取当前的导航控制器
        var navigationController: UINavigationController?

        if let nav = topVC.navigationController {
            navigationController = nav
        } else if let nav = topVC as? UINavigationController {
            navigationController = nav
        }

        guard let navController = navigationController else { return false }

        // 检查索引是否有效
        let viewControllers = navController.viewControllers
        guard index >= 0 && index < viewControllers.count else { return false }

        // 返回到指定索引的视图控制器
        let targetViewController = viewControllers[index]
        navController.popToViewController(targetViewController, animated: animated)

        return true
    }

    /// 返回到NavigationController中指定类型的页面
    /// - Parameters:
    ///   - viewControllerType: 目标页面的类型
    ///   - animated: 是否使用动画效果，默认为true
    /// - Returns: 是否成功返回到指定类型的页面
    @discardableResult
    static func popToViewController<T: UIViewController>(
        ofType viewControllerType: T.Type, animated: Bool = true
    ) -> Bool {
        guard let topVC = getTopViewController() else { return false }

        // 获取当前的导航控制器
        var navigationController: UINavigationController?

        if let nav = topVC.navigationController {
            navigationController = nav
        } else if let nav = topVC as? UINavigationController {
            navigationController = nav
        }

        guard let navController = navigationController else { return false }

        // 查找指定类型的视图控制器
        for viewController in navController.viewControllers {
            if type(of: viewController) == viewControllerType {
                navController.popToViewController(viewController, animated: animated)
                return true
            }
        }

        navController.popToRootViewController(animated: true)
        return false
    }

    @discardableResult
    static func popBeforeViewController(ofType viewControllerType: UIViewController.Type, animated: Bool) -> Bool {
        guard let topVC = getTopViewController() else { return false }
        
        var navigationController: UINavigationController?
        if let nav = topVC.navigationController {
            navigationController = nav
        } else if let nav = topVC as? UINavigationController {
            navigationController = nav
        }
        guard let navController = navigationController else { return false }
        
        let viewControllers = navController.viewControllers
        for (index, viewController) in viewControllers.enumerated() {
            if type(of: viewController) == viewControllerType {
                if index > 0 {
                    navController.popToViewController(viewControllers[index - 1], animated: animated)
                    return true
                } else {
                    navController.popToRootViewController(animated: animated)
                    return true
                }
            }
        }
        return false
    }

    /// 导航到下一个页面
    /// - Parameters:
    ///   - viewController: 要导航到的视图控制器
    ///   - animated: 是否使用动画效果，默认为true
    /// - Returns: 是否成功导航到下一个页面
    @discardableResult
    static func pushViewController(_ viewController: UIViewController, animated: Bool = true)
        -> Bool
    {
        guard let topVC = getTopViewController() else { return false }

        // 获取当前的导航控制器
        var navigationController: UINavigationController?

        if let nav = topVC.navigationController {
            navigationController = nav
        } else if let nav = topVC as? UINavigationController {
            navigationController = nav
        }

        guard let navController = navigationController else {
            // 如果没有导航控制器，则以模态方式呈现
            topVC.present(viewController, animated: animated)
            return true
        }

        // 使用导航控制器推入新页面
        navController.pushViewController(viewController, animated: animated)
        return true
    }
    
    /// 返回到根视图控制器
    /// - Parameters:
    ///   - animated: 是否使用动画效果，默认为true
    /// - Returns: 是否成功返回到根视图控制器
    @discardableResult
    static func popToRootVC(animated: Bool = true) -> Bool {
        guard let topVC = getTopViewController() else { return false }

        // 获取当前的导航控制器
        var navigationController: UINavigationController?

        if let nav = topVC.navigationController {
            navigationController = nav
        } else if let nav = topVC as? UINavigationController {
            navigationController = nav
        }

        guard let navController = navigationController else { return false }

        // 返回到根视图控制器
        navController.popToRootViewController(animated: animated)
        return true
    }
    
    /// 从指定VC的navigationController栈中向rootVC方向查找某个类型的VC对象
    /// - Parameters:
    ///   - viewController: 起始查找的视图控制器
    ///   - viewControllerType: 要查找的视图控制器类型
    /// - Returns: 找到的指定类型的视图控制器，如果没找到则返回nil
    static func findViewController<T: UIViewController>(
        from viewController: UIViewController,
        ofType viewControllerType: T.Type
    ) -> T? {
        // 获取当前VC的导航控制器
        var navigationController: UINavigationController?
        
        if let nav = viewController.navigationController {
            navigationController = nav
        } else if let nav = viewController as? UINavigationController {
            navigationController = nav
        }
        
        guard let navController = navigationController else { return nil }
        
        let viewControllers = navController.viewControllers
        
        // 从当前VC开始，向rootVC方向查找（索引递减）
        if let currentIndex = viewControllers.firstIndex(where: { $0 === viewController }) {
            // 从当前索引开始，向索引0（rootVC）方向查找
            for index in stride(from: currentIndex, through: 0, by: -1) {
                let vc = viewControllers[index]
                if type(of: vc) == viewControllerType {
                    return vc as? T
                }
            }
        }
        
        return nil
    }
    
    /// 将当前navigationController从栈顶出栈，直到指定控制器时停止，然后执行completeBlock
    /// - Parameters:
    ///   - targetViewController: 目标视图控制器，出栈到此控制器时停止
    ///   - completeBlock: 出栈完成后的回调
    ///   - animated: 是否使用动画效果，默认为true
    /// - Returns: 是否成功执行出栈操作
    @discardableResult
    static func popToViewController(
        _ targetViewController: UIViewController,
        completeBlock: @escaping () -> Void,
        animated: Bool = true
    ) -> Bool {
        guard let topVC = getTopViewController() else { return false }

        // 获取当前的导航控制器
        var navigationController: UINavigationController?

        if let nav = topVC.navigationController {
            navigationController = nav
        } else if let nav = topVC as? UINavigationController {
            navigationController = nav
        }

        guard let navController = navigationController else { return false }

        // 检查目标控制器是否在导航栈中
        let viewControllers = navController.viewControllers
        guard viewControllers.contains(targetViewController) else { return false }

        // 执行出栈操作
        navController.popToViewController(targetViewController, animated: animated)
        
        // 如果使用动画，延迟执行completeBlock；否则立即执行
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                completeBlock()
            }
        } else {
            completeBlock()
        }

        return true
    }
}


extension PageManager {
    /// Returns the current application's top most view controller.
    public class var topMost: UIViewController? {
        var rootViewController: UIViewController?
        // 使用更现代的API获取keyWindow
        let keyWindow: UIWindow?

        if #available(iOS 15.0, *) {
            // iOS 15及以上版本
            keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            // iOS 15以下版本
            keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
        rootViewController = keyWindow?.rootViewController
        return self.topMost(of: rootViewController)
    }
    
    /// Returns the top most view controller from given view controller's stack.
    public class func topMost(of viewController: UIViewController?) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMost(of: presentedViewController)
        }
        
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return self.topMost(of: selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return self.topMost(of: visibleViewController)
        }
        
        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
           pageViewController.viewControllers?.count == 1 {
            return self.topMost(of: pageViewController.viewControllers?.first)
        }
        
        // child view controller
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return self.topMost(of: childViewController)
            }
        }
        return viewController
    }
}

//
//  MainTabBarController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/9/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import BlueToothTool

class MainTabBarController: BaseTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        
    }
    
    private func setupTabBar() {
        // 创建设备页面
        let deviceVC = DeviceViewController()
        let deviceNav = UINavigationController(rootViewController: deviceVC)
        configureNavigationBarAppearance(for: deviceNav)
        deviceNav.tabBarItem = UITabBarItem(
            title: "BLE设备",
            image: UIImage(systemName: "antenna.radiowaves.left.and.right"),
            selectedImage: UIImage(systemName: "antenna.radiowaves.left.and.right")
        )
        
        // 创建日志页面
        let logVC = MFIDeviceViewController()
        let logNav = UINavigationController(rootViewController: logVC)
        configureNavigationBarAppearance(for: logNav)
        logNav.tabBarItem = UITabBarItem(
            title: "MFI设备",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text")
        )
        
        // 创建数据包页面
        let dataPackageVC = CMDDebugViewController()
        let dataPackageNav = UINavigationController(rootViewController: dataPackageVC)
        configureNavigationBarAppearance(for: dataPackageNav)
        dataPackageNav.tabBarItem = UITabBarItem(
            title: "CMD调试",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar")
        )
        
        // 创建设置页面
        let settingVC = MineViewController()
        let settingNav = UINavigationController(rootViewController: settingVC)
        configureNavigationBarAppearance(for: settingNav)
        settingNav.tabBarItem = UITabBarItem(
            title: "我的",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear")
        )
        
        // 设置视图控制器数组
        viewControllers = [deviceNav, logNav, dataPackageNav, settingNav]
        
        // 配置TabBar外观
        configureTabBarAppearance()
    }
    
    /// 配置导航栏外观，确保整个 app 风格一致
    private func configureNavigationBarAppearance(for navigationController: UINavigationController) {
        let navigationBar = navigationController.navigationBar
        
        // iOS 15+ 使用 UINavigationBarAppearance
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Color.lakeBlue
            
            // 设置标题颜色
            appearance.titleTextAttributes = [
                .foregroundColor: Color.white
            ]
            appearance.largeTitleTextAttributes = [
                .foregroundColor: Color.white
            ]
            
            // 设置按钮颜色
            appearance.buttonAppearance.normal.titleTextAttributes = [
                .foregroundColor: Color.white
            ]
            appearance.doneButtonAppearance.normal.titleTextAttributes = [
                .foregroundColor: Color.white
            ]
            
            // 设置返回按钮颜色
            appearance.backButtonAppearance.normal.titleTextAttributes = [
                .foregroundColor: Color.white
            ]
            
            // 应用外观配置
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            
            // 设置按钮颜色（兼容旧版本）
            navigationBar.tintColor = Color.white
        } else {
            // iOS 15 以下版本使用旧 API
            navigationBar.backgroundColor = Color.lakeBlue
            navigationBar.barTintColor = Color.lakeBlue
            navigationBar.tintColor = Color.white
            navigationBar.titleTextAttributes = [
                .foregroundColor: Color.white
            ]
            navigationBar.largeTitleTextAttributes = [
                .foregroundColor: Color.white
            ]
        }
    }
    
    private func configureTabBarAppearance() {
        // 设置TabBar背景色
        tabBar.backgroundColor = Color.white
        
        // 设置选中和未选中的颜色
        tabBar.tintColor = Color.lakeBlue  // 选中时的颜色
        tabBar.unselectedItemTintColor = Color.grayText  // 未选中时的颜色
        
        // 设置TabBar样式
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Color.white
            
            // 设置选中状态的颜色
            appearance.stackedLayoutAppearance.selected.iconColor = Color.lakeBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: Color.lakeBlue
            ]
            
            // 设置未选中状态的颜色
            appearance.stackedLayoutAppearance.normal.iconColor = Color.grayText
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: Color.grayText
            ]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

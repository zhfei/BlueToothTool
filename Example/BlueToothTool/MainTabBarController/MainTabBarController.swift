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
        deviceNav.tabBarItem = UITabBarItem(
            title: "设备",
            image: UIImage(systemName: "antenna.radiowaves.left.and.right"),
            selectedImage: UIImage(systemName: "antenna.radiowaves.left.and.right")
        )
        
        // 创建日志页面
        let logVC = LogViewController()
        let logNav = UINavigationController(rootViewController: logVC)
        logNav.tabBarItem = UITabBarItem(
            title: "日志",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text")
        )
        
        // 创建数据包页面
        let dataPackageVC = DataPackageViewController()
        let dataPackageNav = UINavigationController(rootViewController: dataPackageVC)
        dataPackageNav.tabBarItem = UITabBarItem(
            title: "数据包",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar")
        )
        
        // 创建设置页面
        let settingVC = SettingViewController()
        let settingNav = UINavigationController(rootViewController: settingVC)
        settingNav.tabBarItem = UITabBarItem(
            title: "设置",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear")
        )
        
        // 设置视图控制器数组
        viewControllers = [deviceNav, logNav, dataPackageNav, settingNav]
        
        // 配置TabBar外观
        configureTabBarAppearance()
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

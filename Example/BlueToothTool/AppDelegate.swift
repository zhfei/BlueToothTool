//
//  AppDelegate.swift
//  BlueToothTool
//
//  Created by zhoufei on 09/11/2025.
//  Copyright (c) 2025 zhoufei. All rights reserved.
//

import UIKit
import DoraemonKit
import BlueToothTool

let isDebug = true

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 初始化日志系统
        Logger.shared.setup(
            enableConsoleLog: true,
            enableFileLog: true,
            logLevel: isDebug ? .debug : .info
        )
        
        LogInfo("应用启动完成")
        
        // 配置网络工具
        setupNetwork()
        
        if isDebug {
            DoraemonManager.shareInstance().install()
            DoraemonManager.shareInstance().showDoraemon()
            LogDebug("DoraemonKit 调试工具已启用")
        }
        
        // 设置根视图控制器
        setupRootViewController()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /// 设置根视图控制器
    private func setupRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // 创建主TabBar控制器
        let mainTabBarController = MainTabBarController()
        
        // 设置为根视图控制器
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
        
        LogInfo("根视图控制器设置完成")
    }
    
    /// 配置网络工具
    private func setupNetwork() {
        // 配置基础URL（示例）
        NetworkConfig.shared.configure(baseURL: "https://jsonplaceholder.typicode.com")
        
        // 配置超时时间
        NetworkConfig.shared.configure(timeout: 30.0)
        
        // 配置日志
        NetworkConfig.shared.configureLogging(requestLogging: isDebug, responseLogging: isDebug)
        
        LogInfo("网络工具配置完成")
    }

}


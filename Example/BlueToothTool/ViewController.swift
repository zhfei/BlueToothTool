//
//  ViewController.swift
//  BlueToothTool
//
//  Created by zhoufei on 09/11/2025.
//  Copyright (c) 2025 zhoufei. All rights reserved.
//

import UIKit
import BlueToothTool

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 日志使用示例
        LogInfo("ViewController 加载完成")
        LogDebug("当前视图控制器: \(type(of: self))")
        
        // 测试不同级别的日志
        testLogging()
    }
    
    /// 测试日志功能
    private func testLogging() {
        LogVerbose("这是详细日志")
        LogDebug("这是调试日志")
        LogInfo("这是信息日志")
        LogWarning("这是警告日志")
        LogError("这是错误日志")
        
        // 测试带错误对象的日志
        let testError = NSError(domain: "TestDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "这是一个测试错误"])
        LogError("测试错误日志", error: testError)
        
        // 测试日志文件功能
        if let logPath = Logger.shared.getLatestLogFilePath() {
            LogInfo("最新日志文件路径: \(logPath)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


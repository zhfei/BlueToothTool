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
        
        // 测试网络功能
        testNetworkRequests()
    }
    
    /// 测试网络请求功能
    private func testNetworkRequests() {
        LogInfo("开始测试网络请求功能")
        
        // 测试 GET 请求
        testGetRequest()
        
        // 测试 POST 请求
        testPostRequest()
        
        // 测试网络状态
        testNetworkStatus()
    }
    
    /// 测试 GET 请求
    private func testGetRequest() {
        LogInfo("测试 GET 请求")
        
        NetworkAPI.get(
            "/posts/1",
            responseType: Post.self
        ) { result in
            switch result {
            case .success(let post):
                LogInfo("GET 请求成功: \(post.title)")
            case .failure(let error):
                LogError("GET 请求失败", error: error)
            }
        }
    }
    
    /// 测试 POST 请求
    private func testPostRequest() {
        LogInfo("测试 POST 请求")
        
        let parameters = [
            "title": "测试标题",
            "body": "测试内容",
            "userId": 1
        ] as [String : Any]
        
        NetworkAPI.post(
            "/posts",
            parameters: parameters,
            responseType: Post.self
        ) { result in
            switch result {
            case .success(let post):
                LogInfo("POST 请求成功: \(post.title)")
            case .failure(let error):
                LogError("POST 请求失败", error: error)
            }
        }
    }
    
    /// 测试网络状态
    private func testNetworkStatus() {
        LogInfo("测试网络状态")
        
        if NetworkAPI.isNetworkReachable {
            LogInfo("网络连接正常")
            
            switch NetworkAPI.networkConnectionType {
            case .reachable(.ethernetOrWiFi):
                LogInfo("WiFi 连接")
            case .reachable(.cellular):
                LogInfo("蜂窝网络连接")
            case .notReachable:
                LogWarning("无网络连接")
            case .unknown:
                LogWarning("网络状态未知")
            }
        } else {
            LogError("网络连接不可用")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - 测试数据模型
struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

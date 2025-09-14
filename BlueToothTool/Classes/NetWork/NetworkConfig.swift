//
//  NetworkConfig.swift
//  BlueToothTool
//
//  Created by zhoufei on 2024/12/19.
//

import Foundation
import Alamofire

/// 网络请求配置类
public class NetworkConfig {
    
    /// 单例实例
    public static let shared = NetworkConfig()
    
    /// 基础URL
    public var baseURL: String = ""
    
    /// 请求超时时间（秒）
    public var timeoutInterval: TimeInterval = 30.0
    
    /// 默认请求头
    public var defaultHeaders: HTTPHeaders = HTTPHeaders()
    
    /// 是否显示网络活动指示器
    public var showNetworkActivityIndicator: Bool = true
    
    /// 是否打印请求日志
    public var enableRequestLogging: Bool = true
    
    /// 是否打印响应日志
    public var enableResponseLogging: Bool = true
    
    /// 网络状态监听器
    public var networkReachabilityManager: NetworkReachabilityManager?
    
    private init() {
        setupDefaultHeaders()
        setupNetworkReachability()
    }
    
    /// 设置默认请求头
    private func setupDefaultHeaders() {
        defaultHeaders.add(name: "Content-Type", value: "application/json")
        defaultHeaders.add(name: "Accept", value: "application/json")
        defaultHeaders.add(name: "User-Agent", value: getUserAgent())
    }
    
    /// 获取用户代理字符串
    private func getUserAgent() -> String {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "BlueToothTool"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let systemVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model
        
        return "\(appName)/\(appVersion) (\(deviceModel); iOS \(systemVersion))"
    }
    
    /// 设置网络可达性监听
    private func setupNetworkReachability() {
        networkReachabilityManager = NetworkReachabilityManager()
        networkReachabilityManager?.startListening { status in
            switch status {
            case .reachable(let connectionType):
                print("网络连接正常: \(connectionType)")
            case .notReachable:
                print("网络连接不可用")
            case .unknown:
                print("网络状态未知")
            }
        }
    }
    
    /// 检查网络连接状态
    public var isNetworkReachable: Bool {
        return networkReachabilityManager?.isReachable ?? false
    }
    
    /// 获取网络连接类型
    public var networkConnectionType: NetworkReachabilityManager.NetworkReachabilityStatus {
        return networkReachabilityManager?.status ?? .unknown
    }
    
    /// 添加默认请求头
    /// - Parameters:
    ///   - name: 头部名称
    ///   - value: 头部值
    public func addDefaultHeader(name: String, value: String) {
        defaultHeaders.add(name: name, value: value)
    }
    
    /// 移除默认请求头
    /// - Parameter name: 头部名称
    public func removeDefaultHeader(name: String) {
        defaultHeaders.remove(name: name)
    }
    
    /// 设置认证Token
    /// - Parameter token: 认证Token
    public func setAuthToken(_ token: String) {
        addDefaultHeader(name: "Authorization", value: "Bearer \(token)")
    }
    
    /// 清除认证Token
    public func clearAuthToken() {
        removeDefaultHeader(name: "Authorization")
    }
    
    /// 配置基础URL
    /// - Parameter url: 基础URL
    public func configure(baseURL url: String) {
        self.baseURL = url
    }
    
    /// 配置超时时间
    /// - Parameter timeout: 超时时间（秒）
    public func configure(timeout: TimeInterval) {
        self.timeoutInterval = timeout
    }
    
    /// 配置日志开关
    /// - Parameters:
    ///   - requestLogging: 是否打印请求日志
    ///   - responseLogging: 是否打印响应日志
    public func configureLogging(requestLogging: Bool, responseLogging: Bool) {
        self.enableRequestLogging = requestLogging
        self.enableResponseLogging = responseLogging
    }
}

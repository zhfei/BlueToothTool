//
//  NetworkAPI.swift
//  BlueToothTool
//
//  Created by zhoufei on 2024/12/19.
//

import Foundation
import Alamofire

/// 网络请求便捷API
public class NetworkAPI {
    
    /// 网络管理器
    private static let manager = NetworkManager.shared
    
    // MARK: - GET请求
    
    /// GET请求
    /// - Parameters:
    ///   - url: 请求URL
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - responseType: 响应类型
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func get<T: Codable>(
        _ url: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        let requestParams: RequestParameters? = parameters.map { .url($0) }
        return manager.request(
            url: url,
            method: .get,
            parameters: requestParams,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    // MARK: - POST请求
    
    /// POST请求（JSON）
    /// - Parameters:
    ///   - url: 请求URL
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - responseType: 响应类型
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func post<T: Codable>(
        _ url: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        let requestParams: RequestParameters? = parameters.map { .json($0) }
        return manager.request(
            url: url,
            method: .post,
            parameters: requestParams,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    /// POST请求（表单）
    /// - Parameters:
    ///   - url: 请求URL
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - responseType: 响应类型
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func postForm<T: Codable>(
        _ url: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        let requestParams: RequestParameters? = parameters.map { .form($0) }
        return manager.request(
            url: url,
            method: .post,
            parameters: requestParams,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    // MARK: - PUT请求
    
    /// PUT请求
    /// - Parameters:
    ///   - url: 请求URL
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - responseType: 响应类型
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func put<T: Codable>(
        _ url: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        let requestParams: RequestParameters? = parameters.map { .json($0) }
        return manager.request(
            url: url,
            method: .put,
            parameters: requestParams,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    // MARK: - DELETE请求
    
    /// DELETE请求
    /// - Parameters:
    ///   - url: 请求URL
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - responseType: 响应类型
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func delete<T: Codable>(
        _ url: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        let requestParams: RequestParameters? = parameters.map { .url($0) }
        return manager.request(
            url: url,
            method: .delete,
            parameters: requestParams,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    // MARK: - PATCH请求
    
    /// PATCH请求
    /// - Parameters:
    ///   - url: 请求URL
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - responseType: 响应类型
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func patch<T: Codable>(
        _ url: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        let requestParams: RequestParameters? = parameters.map { .json($0) }
        return manager.request(
            url: url,
            method: .patch,
            parameters: requestParams,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    // MARK: - 文件上传
    
    /// 上传单个文件
    /// - Parameters:
    ///   - url: 上传URL
    ///   - file: 文件
    ///   - parameters: 其他参数
    ///   - headers: 请求头
    ///   - progress: 进度回调
    ///   - responseType: 响应类型
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func upload<T: Codable>(
        _ url: String,
        file: MultipartFile,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        progress: ((UploadProgress) -> Void)? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        return manager.upload(
            url: url,
            files: [file],
            parameters: parameters,
            headers: headers,
            progress: progress,
            responseType: responseType,
            completion: completion
        )
    }
    
    /// 上传多个文件
    /// - Parameters:
    ///   - url: 上传URL
    ///   - files: 文件数组
    ///   - parameters: 其他参数
    ///   - headers: 请求头
    ///   - progress: 进度回调
    ///   - responseType: 响应类型
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func uploadMultiple<T: Codable>(
        _ url: String,
        files: [MultipartFile],
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        progress: ((UploadProgress) -> Void)? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        return manager.upload(
            url: url,
            files: files,
            parameters: parameters,
            headers: headers,
            progress: progress,
            responseType: responseType,
            completion: completion
        )
    }
    
    // MARK: - 文件下载
    
    /// 下载文件到Documents目录
    /// - Parameters:
    ///   - url: 下载URL
    ///   - fileName: 文件名
    ///   - headers: 请求头
    ///   - progress: 进度回调
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func download(
        _ url: String,
        fileName: String,
        headers: HTTPHeaders? = nil,
        progress: ((DownloadProgress) -> Void)? = nil,
        completion: @escaping (NetworkResult<URL>) -> Void
    ) -> String {
        
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(fileName)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return manager.download(
            url: url,
            destination: destination,
            headers: headers,
            progress: progress,
            completion: completion
        )
    }
    
    /// 下载文件到指定目录
    /// - Parameters:
    ///   - url: 下载URL
    ///   - destination: 保存路径
    ///   - headers: 请求头
    ///   - progress: 进度回调
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public static func downloadTo(
        _ url: String,
        destination: @escaping DownloadRequest.Destination,
        headers: HTTPHeaders? = nil,
        progress: ((DownloadProgress) -> Void)? = nil,
        completion: @escaping (NetworkResult<URL>) -> Void
    ) -> String {
        
        return manager.download(
            url: url,
            destination: destination,
            headers: headers,
            progress: progress,
            completion: completion
        )
    }
    
    // MARK: - 请求管理
    
    /// 取消请求
    /// - Parameter taskId: 任务标识
    public static func cancel(_ taskId: String) {
        manager.cancelRequest(taskId: taskId)
    }
    
    /// 取消所有请求
    public static func cancelAll() {
        manager.cancelAllRequests()
    }
    
    // MARK: - 网络状态
    
    /// 检查网络连接状态
    public static var isNetworkReachable: Bool {
        return NetworkConfig.shared.isNetworkReachable
    }
    
    /// 获取网络连接类型
    public static var networkConnectionType: NetworkReachabilityManager.NetworkReachabilityStatus {
        return NetworkConfig.shared.networkConnectionType
    }
}

// MARK: - 便捷扩展

/// 响应数据扩展
public extension NetworkAPI {
    
    /// 获取字符串响应
    /// - Parameters:
    ///   - url: 请求URL
    ///   - method: HTTP方法
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    static func requestString(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (NetworkResult<String>) -> Void
    ) -> String {
        
        let requestParams: RequestParameters? = parameters.map { .url($0) }
        return manager.request(
            url: url,
            method: method,
            parameters: requestParams,
            headers: headers,
            responseType: String.self,
            completion: completion
        )
    }
    
    /// 获取Data响应
    /// - Parameters:
    ///   - url: 请求URL
    ///   - method: HTTP方法
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    static func requestData(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (NetworkResult<Data>) -> Void
    ) -> String {
        
        let requestParams: RequestParameters? = parameters.map { .url($0) }
        return manager.request(
            url: url,
            method: method,
            parameters: requestParams,
            headers: headers,
            responseType: Data.self,
            completion: completion
        )
    }
}

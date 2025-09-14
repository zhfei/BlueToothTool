//
//  NetworkManager.swift
//  BlueToothTool
//
//  Created by zhoufei on 2024/12/19.
//

import Foundation
import Alamofire
import UIKit

/// 网络请求管理器
public class NetworkManager {
    
    /// 单例实例
    public static let shared = NetworkManager()
    
    /// Session管理器
    private let session: Session
    
    /// 网络配置
    private let config = NetworkConfig.shared
    
    /// 当前请求任务
    private var currentTasks: [String: DataRequest] = [:]
    
    private init() {
        // 配置Session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = config.timeoutInterval
        configuration.timeoutIntervalForResource = config.timeoutInterval
        
        // 创建Session
        session = Session(configuration: configuration)
        
        // 设置网络活动指示器
        setupNetworkActivityIndicator()
    }
    
    /// 设置网络活动指示器
    private func setupNetworkActivityIndicator() {
        session.session.configuration.timeoutIntervalForRequest = config.timeoutInterval
    }
    
    // MARK: - 基础请求方法
    
    /// 发送请求
    /// - Parameters:
    ///   - url: 请求URL
    ///   - method: HTTP方法
    ///   - parameters: 请求参数
    ///   - headers: 请求头
    ///   - encoding: 参数编码方式
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public func request<T: Codable>(
        url: String,
        method: HTTPMethod = .get,
        parameters: RequestParameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        let taskId = UUID().uuidString
        
        // 检查网络连接
        guard config.isNetworkReachable else {
            completion(.failure(.noNetwork))
            return taskId
        }
        
        // 构建完整URL
        let fullURL = buildURL(from: url)
        
        // 构建请求头
        let requestHeaders = buildHeaders(customHeaders: headers)
        
        // 构建参数
        let (finalParameters, finalEncoding) = buildParameters(parameters: parameters, method: method, encoding: encoding)
        
        // 打印请求日志
        if config.enableRequestLogging {
            logRequest(url: fullURL, method: method, parameters: finalParameters, headers: requestHeaders)
        }
        
        // 发送请求
        let dataRequest = session.request(
            fullURL,
            method: method,
            parameters: finalParameters,
            encoding: finalEncoding,
            headers: requestHeaders
        )
        
        // 存储任务
        currentTasks[taskId] = dataRequest
        
        // 处理响应
        dataRequest.responseData { [weak self] response in
            self?.currentTasks.removeValue(forKey: taskId)
            self?.handleResponse(response: response, responseType: responseType, completion: completion)
        }
        
        return taskId
    }
    
    // MARK: - 文件上传
    
    /// 上传文件
    /// - Parameters:
    ///   - url: 上传URL
    ///   - files: 文件数组
    ///   - parameters: 其他参数
    ///   - headers: 请求头
    ///   - progress: 进度回调
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public func upload<T: Codable>(
        url: String,
        files: [MultipartFile],
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        progress: ((UploadProgress) -> Void)? = nil,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) -> String {
        
        let taskId = UUID().uuidString
        
        // 检查网络连接
        guard config.isNetworkReachable else {
            completion(.failure(.noNetwork))
            return taskId
        }
        
        // 构建完整URL
        let fullURL = buildURL(from: url)
        
        // 构建请求头
        let requestHeaders = buildHeaders(customHeaders: headers)
        
        // 创建多部分数据
        session.upload(multipartFormData: { multipartFormData in
            // 添加文件
            for file in files {
                multipartFormData.append(file.data, withName: file.name, fileName: file.fileName, mimeType: file.mimeType)
            }
            
            // 添加其他参数
            if let parameters = parameters {
                for (key, value) in parameters {
                    if let stringValue = value as? String {
                        multipartFormData.append(stringValue.data(using: .utf8) ?? Data(), withName: key)
                    } else if let dataValue = value as? Data {
                        multipartFormData.append(dataValue, withName: key)
                    }
                }
            }
        }, to: fullURL, headers: requestHeaders)
        .uploadProgress { uploadProgress in
            let progressModel = UploadProgress(
                bytesUploaded: uploadProgress.completedUnitCount,
                totalBytes: uploadProgress.totalUnitCount
            )
            progress?(progressModel)
        }
        .responseData { [weak self] response in
            self?.currentTasks.removeValue(forKey: taskId)
            self?.handleResponse(response: response, responseType: responseType, completion: completion)
        }
        
        return taskId
    }
    
    // MARK: - 文件下载
    
    /// 下载文件
    /// - Parameters:
    ///   - url: 下载URL
    ///   - destination: 保存路径
    ///   - headers: 请求头
    ///   - progress: 进度回调
    ///   - completion: 完成回调
    /// - Returns: 请求任务标识
    @discardableResult
    public func download(
        url: String,
        destination: @escaping DownloadRequest.Destination,
        headers: HTTPHeaders? = nil,
        progress: ((DownloadProgress) -> Void)? = nil,
        completion: @escaping (NetworkResult<URL>) -> Void
    ) -> String {
        
        let taskId = UUID().uuidString
        
        // 检查网络连接
        guard config.isNetworkReachable else {
            completion(.failure(.noNetwork))
            return taskId
        }
        
        // 构建完整URL
        let fullURL = buildURL(from: url)
        
        // 构建请求头
        let requestHeaders = buildHeaders(customHeaders: headers)
        
        // 开始下载
        let downloadRequest = session.download(fullURL, headers: requestHeaders, to: destination)
        
        // 监听下载进度
        downloadRequest.downloadProgress { downloadProgress in
            let progressModel = DownloadProgress(
                bytesDownloaded: downloadProgress.completedUnitCount,
                totalBytes: downloadProgress.totalUnitCount
            )
            progress?(progressModel)
        }
        
        // 处理下载完成
        downloadRequest.responseData { [weak self] response in
            self?.currentTasks.removeValue(forKey: taskId)
            
            switch response.result {
            case .success(let data):
                if let url = response.fileURL {
                    completion(.success(url))
                } else {
                    completion(.failure(.noData))
                }
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
        
        return taskId
    }
    
    // MARK: - 取消请求
    
    /// 取消指定请求
    /// - Parameter taskId: 任务标识
    public func cancelRequest(taskId: String) {
        currentTasks[taskId]?.cancel()
        currentTasks.removeValue(forKey: taskId)
    }
    
    /// 取消所有请求
    public func cancelAllRequests() {
        for (taskId, request) in currentTasks {
            request.cancel()
        }
        currentTasks.removeAll()
    }
    
    // MARK: - 私有方法
    
    /// 构建完整URL
    private func buildURL(from url: String) -> String {
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return url
        } else {
            return config.baseURL + url
        }
    }
    
    /// 构建请求头
    private func buildHeaders(customHeaders: HTTPHeaders?) -> HTTPHeaders {
        var headers = config.defaultHeaders
        
        if let customHeaders = customHeaders {
            for header in customHeaders {
                headers.add(name: header.name, value: header.value)
            }
        }
        
        return headers
    }
    
    /// 构建参数和编码方式
    private func buildParameters(
        parameters: RequestParameters?,
        method: HTTPMethod,
        encoding: ParameterEncoding?
    ) -> ([String: Any]?, ParameterEncoding) {
        
        guard let parameters = parameters else {
            return (nil, URLEncoding.default)
        }
        
        switch parameters {
        case .json(let params):
            return (params, JSONEncoding.default)
        case .url(let params):
            return (params, URLEncoding.default)
        case .form(let params):
            return (params, URLEncoding.default)
        case .multipart(let params, _):
            return (params, URLEncoding.default)
        }
    }
    
    /// 处理响应
    private func handleResponse<T: Codable>(
        response: DataResponse<Data, AFError>,
        responseType: T.Type,
        completion: @escaping (NetworkResult<T>) -> Void
    ) {
        
        // 打印响应日志
        if config.enableResponseLogging {
            logResponse(response: response)
        }
        
        switch response.result {
        case .success(let data):
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        case .failure(let error):
            if error.isExplicitlyCancelledError {
                completion(.failure(.cancelled))
            } else if error.isSessionTaskError {
                completion(.failure(.timeout))
            } else {
                completion(.failure(.networkError(error)))
            }
        }
    }
    
    /// 打印请求日志
    private func logRequest(url: String, method: HTTPMethod, parameters: [String: Any]?, headers: HTTPHeaders) {
        print("🌐 [REQUEST] \(method.rawValue) \(url)")
        if let parameters = parameters {
            print("📝 [PARAMETERS] \(parameters)")
        }
        print("📋 [HEADERS] \(headers.dictionary)")
    }
    
    /// 打印响应日志
    private func logResponse(response: DataResponse<Data, AFError>) {
        if let statusCode = response.response?.statusCode {
            print("📡 [RESPONSE] Status: \(statusCode)")
        }
        
        if let data = response.data {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 [RESPONSE DATA] \(jsonString)")
            }
        }
        
        if let error = response.error {
            print("❌ [ERROR] \(error.localizedDescription)")
        }
    }
}

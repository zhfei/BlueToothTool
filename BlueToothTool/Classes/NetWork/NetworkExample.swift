//
//  NetworkExample.swift
//  BlueToothTool
//
//  Created by zhoufei on 2024/12/19.
//

import Foundation
import UIKit
import Alamofire

/// 网络请求使用示例
public class NetworkExample {
    
    /// 用户模型示例
    public struct User: Codable {
        let id: Int
        let name: String
        let email: String
        let avatar: String?
    }
    
    /// 登录请求模型
    public struct LoginRequest: Codable {
        let username: String
        let password: String
    }
    
    /// 登录响应模型
    public struct LoginResponse: Codable {
        let token: String
        let user: User
        let expiresIn: Int
    }
    
    /// 示例：配置网络
    public static func setupNetwork() {
        // 配置基础URL
        NetworkConfig.shared.configure(baseURL: "https://api.example.com")
        
        // 配置超时时间
        NetworkConfig.shared.configure(timeout: 30.0)
        
        // 配置日志
        NetworkConfig.shared.configureLogging(requestLogging: true, responseLogging: true)
        
        // 设置认证Token（登录后）
        // NetworkConfig.shared.setAuthToken("your_token_here")
    }
    
    /// 示例：GET请求
    public static func getUserInfo(userId: Int, completion: @escaping (NetworkResult<User>) -> Void) {
        NetworkAPI.get(
            "/users/\(userId)",
            responseType: User.self,
            completion: completion
        )
    }
    
    /// 示例：POST请求（JSON）
    public static func login(username: String, password: String, completion: @escaping (NetworkResult<LoginResponse>) -> Void) {
        let parameters = [
            "username": username,
            "password": password
        ]
        
        NetworkAPI.post(
            "/auth/login",
            parameters: parameters,
            responseType: LoginResponse.self,
            completion: completion
        )
    }
    
    /// 示例：POST请求（表单）
    public static func updateProfile(name: String, email: String, completion: @escaping (NetworkResult<User>) -> Void) {
        let parameters = [
            "name": name,
            "email": email
        ]
        
        NetworkAPI.postForm(
            "/users/profile",
            parameters: parameters,
            responseType: User.self,
            completion: completion
        )
    }
    
    /// 示例：PUT请求
    public static func updateUser(userId: Int, user: User, completion: @escaping (NetworkResult<User>) -> Void) {
        let parameters = [
            "name": user.name,
            "email": user.email,
            "avatar": user.avatar ?? ""
        ]
        
        NetworkAPI.put(
            "/users/\(userId)",
            parameters: parameters,
            responseType: User.self,
            completion: completion
        )
    }
    
    /// 示例：DELETE请求
    public static func deleteUser(userId: Int, completion: @escaping (NetworkResult<String>) -> Void) {
        NetworkAPI.delete(
            "/users/\(userId)",
            responseType: String.self,
            completion: completion
        )
    }
    
    /// 示例：文件上传
    public static func uploadAvatar(image: UIImage, userId: Int, completion: @escaping (NetworkResult<String>) -> Void) {
        guard let file = MultipartFile.from(image: image, name: "avatar", fileName: "avatar.jpg") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let parameters = [
            "user_id": userId
        ]
        
        NetworkAPI.upload(
            "/users/avatar",
            file: file,
            parameters: parameters,
            progress: { progress in
                print("上传进度: \(Int(progress.progress * 100))%")
            },
            responseType: String.self,
            completion: completion
        )
    }
    
    /// 示例：多文件上传
    public static func uploadImages(images: [UIImage], completion: @escaping (NetworkResult<[String]>) -> Void) {
        let files = images.enumerated().compactMap { index, image in
            MultipartFile.from(image: image, name: "images", fileName: "image_\(index).jpg")
        }
        
        NetworkAPI.uploadMultiple(
            "/upload/images",
            files: files,
            progress: { progress in
                print("上传进度: \(Int(progress.progress * 100))%")
            },
            responseType: [String].self,
            completion: completion
        )
    }
    
    /// 示例：文件下载
    public static func downloadFile(url: String, fileName: String, completion: @escaping (NetworkResult<URL>) -> Void) {
        NetworkAPI.download(
            url,
            fileName: fileName,
            progress: { progress in
                print("下载进度: \(Int(progress.progress * 100))%")
            },
            completion: completion
        )
    }
    
    /// 示例：自定义下载路径
    public static func downloadToCustomPath(url: String, completion: @escaping (NetworkResult<URL>) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let customFolder = documentsURL.appendingPathComponent("Downloads")
            let fileURL = customFolder.appendingPathComponent("downloaded_file.pdf")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        NetworkAPI.downloadTo(
            url,
            destination: destination,
            progress: { progress in
                print("下载进度: \(Int(progress.progress * 100))%")
            },
            completion: completion
        )
    }
    
    /// 示例：带自定义请求头的请求
    public static func requestWithCustomHeaders(completion: @escaping (NetworkResult<User>) -> Void) {
        let headers: HTTPHeaders = [
            "X-Custom-Header": "custom-value",
            "X-API-Version": "v1"
        ]
        
        NetworkAPI.get(
            "/users/me",
            headers: headers,
            responseType: User.self,
            completion: completion
        )
    }
    
    /// 示例：处理网络错误
    public static func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .noNetwork:
            print("网络连接不可用，请检查网络设置")
        case .timeout:
            print("请求超时，请稍后重试")
        case .serverError(let code, let message):
            print("服务器错误(\(code)): \(message ?? "未知错误")")
        case .decodingError(let error):
            print("数据解析失败: \(error.localizedDescription)")
        default:
            print("网络请求失败: \(error.localizedDescription)")
        }
    }
    
    /// 示例：完整的请求流程
    public static func completeRequestExample() {
        // 1. 配置网络
        setupNetwork()
        
        // 2. 检查网络状态
        guard NetworkAPI.isNetworkReachable else {
            print("网络不可用")
            return
        }
        
        // 3. 发送请求
        let taskId = NetworkAPI.get(
            "/users/1",
            responseType: User.self
        ) { result in
            switch result {
            case .success(let user):
                print("获取用户信息成功: \(user.name)")
            case .failure(let error):
                handleNetworkError(error)
            }
        }
        
        // 4. 如果需要，可以取消请求
        // NetworkAPI.cancel(taskId)
    }
}

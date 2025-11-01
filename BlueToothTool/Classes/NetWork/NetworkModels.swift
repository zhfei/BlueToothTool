//
//  NetworkModels.swift
//  BlueToothTool
//
//  Created by zhoufei on 2024/12/19.
//

import Foundation
import Alamofire

/// 网络请求结果枚举
public enum NetworkResult<T> {
    case success(T)
    case failure(NetworkError)
}

/// 网络错误类型
public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int, String?)
    case timeout
    case noNetwork
    case cancelled
    case unknown(Error)
    case unsupportedParameters(String)
    
    /// 错误描述
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "没有数据返回"
        case .decodingError(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "服务器错误(\(code)): \(message ?? "未知错误")"
        case .timeout:
            return "请求超时"
        case .noNetwork:
            return "网络连接不可用"
        case .cancelled:
            return "请求已取消"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        case .unsupportedParameters(let message):
            return "不支持的请求参数类型: \(message)"
        }
    }
    
    /// 错误代码
    public var code: Int {
        switch self {
        case .invalidURL:
            return -1001
        case .noData:
            return -1002
        case .decodingError:
            return -1003
        case .networkError:
            return -1004
        case .serverError(let code, _):
            return code
        case .timeout:
            return -1005
        case .noNetwork:
            return -1006
        case .cancelled:
            return -1007
        case .unknown:
            return -1008
        case .unsupportedParameters:
            return -1009
        }
    }
}

/// 通用响应模型
public struct NetworkResponse<T: Codable>: Codable {
    public let code: Int
    public let message: String
    public let data: T?
    public let success: Bool
    
    public init(code: Int, message: String, data: T?, success: Bool) {
        self.code = code
        self.message = message
        self.data = data
        self.success = success
    }
}

/// 分页响应模型
public struct PaginatedResponse<T: Codable>: Codable {
    public let code: Int
    public let message: String
    public let data: PaginatedData<T>?
    public let success: Bool
    
    public init(code: Int, message: String, data: PaginatedData<T>?, success: Bool) {
        self.code = code
        self.message = message
        self.data = data
        self.success = success
    }
}

/// 分页数据模型
public struct PaginatedData<T: Codable>: Codable {
    public let list: [T]
    public let total: Int
    public let page: Int
    public let pageSize: Int
    public let hasMore: Bool
    
    public init(list: [T], total: Int, page: Int, pageSize: Int, hasMore: Bool) {
        self.list = list
        self.total = total
        self.page = page
        self.pageSize = pageSize
        self.hasMore = hasMore
    }
}

/// 上传进度模型
public struct UploadProgress {
    public let bytesUploaded: Int64
    public let totalBytes: Int64
    public let progress: Double
    
    public init(bytesUploaded: Int64, totalBytes: Int64) {
        self.bytesUploaded = bytesUploaded
        self.totalBytes = totalBytes
        self.progress = totalBytes > 0 ? Double(bytesUploaded) / Double(totalBytes) : 0.0
    }
}

/// 下载进度模型
public struct DownloadProgress {
    public let bytesDownloaded: Int64
    public let totalBytes: Int64
    public let progress: Double
    
    public init(bytesDownloaded: Int64, totalBytes: Int64) {
        self.bytesDownloaded = bytesDownloaded
        self.totalBytes = totalBytes
        self.progress = totalBytes > 0 ? Double(bytesDownloaded) / Double(totalBytes) : 0.0
    }
}

/// 请求参数类型
public enum RequestParameters {
    case json([String: Any])
    case url([String: Any])
    case form([String: Any])
    case multipart([String: Any], [MultipartFile])
}

/// 多部分文件上传模型
public struct MultipartFile {
    public let data: Data
    public let name: String
    public let fileName: String
    public let mimeType: String
    
    public init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    /// 从UIImage创建
    public static func from(image: UIImage, name: String, fileName: String? = nil) -> MultipartFile? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        let finalFileName = fileName ?? "\(name).jpg"
        return MultipartFile(data: imageData, name: name, fileName: finalFileName, mimeType: "image/jpeg")
    }
    
    /// 从文件URL创建
    public static func from(url: URL, name: String) -> MultipartFile? {
        do {
            let data = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            let mimeType = getMimeType(for: url.pathExtension)
            return MultipartFile(data: data, name: name, fileName: fileName, mimeType: mimeType)
        } catch {
            return nil
        }
    }
    
    /// 获取MIME类型
    private static func getMimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        case "json":
            return "application/json"
        case "mp4":
            return "video/mp4"
        case "mp3":
            return "audio/mpeg"
        default:
            return "application/octet-stream"
        }
    }
}

/// HTTP方法扩展
public extension HTTPMethod {
    /// 是否支持请求体
    var supportsBody: Bool {
        switch self {
        case .post, .put, .patch:
            return true
        default:
            return false
        }
    }
}

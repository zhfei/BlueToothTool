# Network 网络工具使用说明

## 概述
Network 是基于 Alamofire 封装的网络请求工具，提供了简单易用的 API 来处理各种网络请求场景。

## 功能特性
- ✅ 支持 GET、POST、PUT、DELETE、PATCH 请求
- ✅ 支持 JSON、表单、URL 参数编码
- ✅ 支持文件上传（单文件/多文件）
- ✅ 支持文件下载
- ✅ 支持请求进度监听
- ✅ 支持请求取消
- ✅ 支持网络状态监听
- ✅ 支持自定义请求头
- ✅ 支持请求/响应日志
- ✅ 支持错误处理
- ✅ 支持泛型响应解析

## 快速开始

### 1. 配置网络
在 `AppDelegate.swift` 中配置：

```swift
import BlueToothTool

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 配置网络
    NetworkConfig.shared.configure(baseURL: "https://api.example.com")
    NetworkConfig.shared.configure(timeout: 30.0)
    NetworkConfig.shared.configureLogging(requestLogging: true, responseLogging: true)
    
    return true
}
```

### 2. 基础请求

#### GET 请求
```swift
import BlueToothTool

// 获取用户信息
NetworkAPI.get(
    "/users/1",
    responseType: User.self
) { result in
    switch result {
    case .success(let user):
        print("用户: \(user.name)")
    case .failure(let error):
        print("错误: \(error.localizedDescription)")
    }
}
```

#### POST 请求（JSON）
```swift
// 登录
let parameters = [
    "username": "user123",
    "password": "password123"
]

NetworkAPI.post(
    "/auth/login",
    parameters: parameters,
    responseType: LoginResponse.self
) { result in
    switch result {
    case .success(let response):
        print("登录成功: \(response.token)")
    case .failure(let error):
        print("登录失败: \(error.localizedDescription)")
    }
}
```

#### POST 请求（表单）
```swift
NetworkAPI.postForm(
    "/users/profile",
    parameters: parameters,
    responseType: User.self,
    completion: completion
)
```

### 3. 文件上传

#### 单文件上传
```swift
// 上传头像
guard let file = MultipartFile.from(image: avatarImage, name: "avatar") else {
    return
}

NetworkAPI.upload(
    "/users/avatar",
    file: file,
    parameters: ["user_id": userId],
    progress: { progress in
        print("上传进度: \(Int(progress.progress * 100))%")
    },
    responseType: String.self
) { result in
    switch result {
    case .success(let url):
        print("上传成功: \(url)")
    case .failure(let error):
        print("上传失败: \(error.localizedDescription)")
    }
}
```

#### 多文件上传
```swift
let files = images.compactMap { image in
    MultipartFile.from(image: image, name: "images")
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
```

### 4. 文件下载

#### 下载到 Documents 目录
```swift
NetworkAPI.download(
    "https://example.com/file.pdf",
    fileName: "document.pdf",
    progress: { progress in
        print("下载进度: \(Int(progress.progress * 100))%")
    }
) { result in
    switch result {
    case .success(let url):
        print("下载完成: \(url)")
    case .failure(let error):
        print("下载失败: \(error.localizedDescription)")
    }
}
```

#### 自定义下载路径
```swift
let destination: DownloadRequest.Destination = { _, _ in
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let customFolder = documentsURL.appendingPathComponent("Downloads")
    let fileURL = customFolder.appendingPathComponent("file.pdf")
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
}

NetworkAPI.downloadTo(
    "https://example.com/file.pdf",
    destination: destination,
    progress: { progress in
        print("下载进度: \(Int(progress.progress * 100))%")
    },
    completion: completion
)
```

## 高级功能

### 1. 自定义请求头
```swift
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
```

### 2. 认证 Token
```swift
// 设置认证 Token
NetworkConfig.shared.setAuthToken("your_token_here")

// 清除认证 Token
NetworkConfig.shared.clearAuthToken()
```

### 3. 请求取消
```swift
// 发送请求并保存任务ID
let taskId = NetworkAPI.get("/users/1", responseType: User.self) { result in
    // 处理结果
}

// 取消请求
NetworkAPI.cancel(taskId)

// 取消所有请求
NetworkAPI.cancelAll()
```

### 4. 网络状态监听
```swift
// 检查网络连接状态
if NetworkAPI.isNetworkReachable {
    print("网络连接正常")
} else {
    print("网络连接不可用")
}

// 获取网络连接类型
let connectionType = NetworkAPI.networkConnectionType
switch connectionType {
case .reachable(.ethernetOrWiFi):
    print("WiFi 连接")
case .reachable(.cellular):
    print("蜂窝网络连接")
case .notReachable:
    print("无网络连接")
case .unknown:
    print("网络状态未知")
}
```

## 数据模型

### 1. 响应模型定义
```swift
// 用户模型
struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let avatar: String?
}

// 通用响应模型
struct NetworkResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
    let success: Bool
}

// 分页响应模型
struct PaginatedResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: PaginatedData<T>?
    let success: Bool
}

struct PaginatedData<T: Codable>: Codable {
    let list: [T]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool
}
```

### 2. 错误处理
```swift
func handleNetworkError(_ error: NetworkError) {
    switch error {
    case .noNetwork:
        print("网络连接不可用，请检查网络设置")
    case .timeout:
        print("请求超时，请稍后重试")
    case .serverError(let code, let message):
        print("服务器错误(\(code)): \(message ?? "未知错误")")
    case .decodingError(let error):
        print("数据解析失败: \(error.localizedDescription)")
    case .cancelled:
        print("请求已取消")
    default:
        print("网络请求失败: \(error.localizedDescription)")
    }
}
```

## 配置选项

### 1. 基础配置
```swift
// 配置基础 URL
NetworkConfig.shared.configure(baseURL: "https://api.example.com")

// 配置超时时间
NetworkConfig.shared.configure(timeout: 30.0)

// 配置日志开关
NetworkConfig.shared.configureLogging(requestLogging: true, responseLogging: true)
```

### 2. 请求头配置
```swift
// 添加默认请求头
NetworkConfig.shared.addDefaultHeader(name: "X-API-Key", value: "your_api_key")

// 移除默认请求头
NetworkConfig.shared.removeDefaultHeader(name: "X-API-Key")

// 设置认证 Token
NetworkConfig.shared.setAuthToken("your_token_here")
```

## 最佳实践

### 1. 错误处理
- 始终处理网络错误
- 根据错误类型提供用户友好的提示
- 记录错误日志便于调试

### 2. 进度监听
- 对于文件上传/下载，提供进度反馈
- 使用进度条提升用户体验

### 3. 请求管理
- 在页面销毁时取消未完成的请求
- 避免重复请求

### 4. 网络状态
- 在发送请求前检查网络状态
- 提供离线模式支持

## 注意事项

1. **线程安全**: 所有网络请求都在后台线程执行，回调在主线程
2. **内存管理**: 使用 `[weak self]` 避免循环引用
3. **错误处理**: 始终处理可能的网络错误
4. **请求取消**: 在适当时机取消不需要的请求
5. **日志记录**: 生产环境建议关闭详细日志

## 故障排除

### 常见问题

1. **请求超时**
   - 检查网络连接
   - 调整超时时间设置

2. **数据解析失败**
   - 检查响应数据格式
   - 确认模型定义正确

3. **认证失败**
   - 检查 Token 是否有效
   - 确认请求头设置正确

4. **文件上传失败**
   - 检查文件大小限制
   - 确认文件格式支持

# Logger 日志工具使用说明

## 概述
Logger 是基于 CocoaLumberjack 封装的通用日志工具类，提供了简单易用的日志记录功能。

## 功能特性
- ✅ 支持多种日志级别（Verbose、Debug、Info、Warning、Error）
- ✅ 支持控制台和文件双重输出
- ✅ 自动文件轮转和过期清理
- ✅ 异步日志记录，不影响主线程性能
- ✅ 自动获取文件名、函数名和行号
- ✅ 支持错误对象日志记录
- ✅ 提供便捷的全局方法

## 快速开始

### 1. 初始化日志系统
在 `AppDelegate.swift` 中初始化：

```swift
import BlueToothTool

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 初始化日志系统
    Logger.shared.setup(
        enableConsoleLog: true,    // 启用控制台日志
        enableFileLog: true,       // 启用文件日志
        logLevel: .debug           // 设置日志级别
    )
    
    LogInfo("应用启动完成")
    return true
}
```

### 2. 使用日志记录

#### 方式一：使用全局便捷方法（推荐）
```swift
import BlueToothTool

// 不同级别的日志
LogVerbose("详细日志信息")
LogDebug("调试日志信息")
LogInfo("信息日志")
LogWarning("警告日志")
LogError("错误日志")

// 带错误对象的日志
LogError("网络请求失败", error: networkError)
```

#### 方式二：使用 Logger 实例
```swift
import BlueToothTool

Logger.shared.debug("调试信息")
Logger.shared.info("普通信息")
Logger.shared.warning("警告信息")
Logger.shared.error("错误信息")
```

## 配置选项

### 日志级别
```swift
public enum LogLevel: Int {
    case verbose = 0    // 详细日志
    case debug = 1     // 调试日志
    case info = 2      // 信息日志
    case warning = 3   // 警告日志
    case error = 4     // 错误日志
}
```

### 初始化参数
```swift
Logger.shared.setup(
    enableConsoleLog: Bool = true,     // 是否启用控制台日志
    enableFileLog: Bool = true,        // 是否启用文件日志
    logLevel: LogLevel = .debug,       // 日志级别
    logDirectory: String? = nil       // 自定义日志目录
)
```

## 高级功能

### 获取日志文件
```swift
// 获取所有日志文件路径
let logPaths = Logger.shared.getLogFilePaths()

// 获取最新日志文件路径
if let latestLogPath = Logger.shared.getLatestLogFilePath() {
    LogInfo("最新日志文件: \(latestLogPath)")
}
```

### 清理过期日志
```swift
// 手动清理过期日志文件
Logger.shared.cleanOldLogFiles()
```

### 动态调整日志级别
```swift
// 运行时调整日志级别
Logger.shared.setLogLevel(.info)
```

## 日志文件管理

### 文件配置
- **文件大小限制**: 10MB
- **轮转频率**: 24小时
- **保留文件数**: 7个
- **存储位置**: Documents/Logs/ (可自定义)

### 文件命名规则
```
BlueToothTool-YYYY-MM-DD-HHMMSS.log
```

## 最佳实践

### 1. 日志级别使用建议
- **Verbose**: 详细的执行流程，仅在调试时使用
- **Debug**: 调试信息，开发阶段使用
- **Info**: 重要的业务信息，生产环境保留
- **Warning**: 警告信息，需要关注但不影响运行
- **Error**: 错误信息，必须记录和处理

### 2. 日志内容建议
```swift
// ✅ 好的日志
LogInfo("用户登录成功，用户ID: \(userId)")
LogError("网络请求失败", error: error)
LogDebug("开始加载数据，URL: \(url)")

// ❌ 避免的日志
LogInfo("开始")
LogDebug("test")
LogError("错误")
```

### 3. 性能考虑
- 日志记录是异步的，不会阻塞主线程
- 生产环境建议设置合适的日志级别（如 .info 或 .warning）
- 定期清理过期日志文件

## 注意事项

1. **初始化**: Logger 只能初始化一次，重复初始化会被忽略
2. **线程安全**: 所有日志方法都是线程安全的
3. **文件权限**: 确保应用有写入 Documents 目录的权限
4. **存储空间**: 注意监控日志文件占用的存储空间

## 故障排除

### 日志文件无法创建
- 检查应用的文件写入权限
- 确认 Documents 目录可访问

### 日志不显示
- 确认 Logger 已正确初始化
- 检查日志级别设置
- 确认控制台日志已启用

### 性能问题
- 检查是否在生产环境使用了过低的日志级别
- 考虑定期清理日志文件

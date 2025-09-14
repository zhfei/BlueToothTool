//
//  Logger.swift
//  BlueToothTool
//
//  Created by zhoufei on 2024/12/19.
//

import Foundation
import CocoaLumberjack

/// 通用日志工具类
/// 基于 CocoaLumberjack 封装的简单易用的日志工具
public class Logger {
    
    /// 日志级别枚举
    public enum LogLevel: Int {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
        
        var ddLogLevel: DDLogLevel {
            switch self {
            case .verbose: return .verbose
            case .debug: return .debug
            case .info: return .info
            case .warning: return .warning
            case .error: return .error
            }
        }
    }
    
    /// 单例实例
    public static let shared = Logger()
    
    /// 是否已初始化
    private var isInitialized = false
    
    /// 文件日志器
    private var fileLogger: DDFileLogger?
    
    private init() {}
    
    /// 初始化日志系统
    /// - Parameters:
    ///   - enableConsoleLog: 是否启用控制台日志，默认 true
    ///   - enableFileLog: 是否启用文件日志，默认 true
    ///   - logLevel: 日志级别，默认 .debug
    ///   - logDirectory: 日志文件目录，默认 Documents/Logs
    public func setup(enableConsoleLog: Bool = true,
                     enableFileLog: Bool = true,
                     logLevel: LogLevel = .debug,
                     logDirectory: String? = nil) {
        
        guard !isInitialized else {
            DDLogWarn("Logger 已经初始化过了")
            return
        }
        
        // 设置日志级别
        dynamicLogLevel = logLevel.ddLogLevel
        
        // 控制台日志
        if enableConsoleLog, let logger = DDTTYLogger.sharedInstance  {
            DDLog.add(DDOSLogger.sharedInstance)
            DDLog.add(logger)
        }
        
        // 文件日志
        if enableFileLog {
            setupFileLogger(logDirectory: logDirectory)
        }
        
        isInitialized = true
        
        // 记录初始化日志
        DDLogInfo("Logger 初始化完成 - 控制台日志: \(enableConsoleLog), 文件日志: \(enableFileLog), 日志级别: \(logLevel)")
    }
    
    /// 设置文件日志器
    private func setupFileLogger(logDirectory: String?) {
        // 创建自定义的日志文件管理器
        let fileManager: DDLogFileManagerDefault
        if let customDirectory = logDirectory {
            fileManager = DDLogFileManagerDefault(logsDirectory: customDirectory)
        } else {
            fileManager = DDLogFileManagerDefault()
        }
        
        fileLogger = DDFileLogger(logFileManager: fileManager)
        
        // 设置日志文件配置
        fileLogger?.maximumFileSize = 1024 * 1024 * 10 // 10MB
        fileLogger?.rollingFrequency = 60 * 60 * 24 // 24小时
        
        // 设置文件管理器配置
        fileManager.maximumNumberOfLogFiles = 7 // 保留7个文件
        
        DDLog.add(fileLogger!)
    }
    
    // MARK: - 公共日志方法
    
    /// 详细日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 文件名（自动获取）
    ///   - function: 函数名（自动获取）
    ///   - line: 行号（自动获取）
    public func verbose(_ message: String,
                       file: StaticString = #file,
                       function: StaticString = #function,
                       line: UInt = #line) {
        DDLogVerbose(message, file: file, function: function, line: line)
    }
    
    /// 调试日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 文件名（自动获取）
    ///   - function: 函数名（自动获取）
    ///   - line: 行号（自动获取）
    public func debug(_ message: String,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        DDLogDebug(message, file: file, function: function, line: line)
    }
    
    /// 信息日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 文件名（自动获取）
    ///   - function: 函数名（自动获取）
    ///   - line: 行号（自动获取）
    public func info(_ message: String,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        DDLogInfo(message, file: file, function: function, line: line)
    }
    
    /// 警告日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 文件名（自动获取）
    ///   - function: 函数名（自动获取）
    ///   - line: 行号（自动获取）
    public func warning(_ message: String,
                        file: StaticString = #file,
                        function: StaticString = #function,
                        line: UInt = #line) {
        DDLogWarn(message, file: file, function: function, line: line)
    }
    
    /// 错误日志
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 文件名（自动获取）
    ///   - function: 函数名（自动获取）
    ///   - line: 行号（自动获取）
    public func error(_ message: String,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        DDLogError(message, file: file, function: function, line: line)
    }
    
    /// 错误日志（带错误对象）
    /// - Parameters:
    ///   - message: 日志消息
    ///   - error: 错误对象
    ///   - file: 文件名（自动获取）
    ///   - function: 函数名（自动获取）
    ///   - line: 行号（自动获取）
    public func error(_ message: String,
                      error: Error,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        DDLogError("\(message) - Error: \(error.localizedDescription)", file: file, function: function, line: line)
    }
    
    // MARK: - 工具方法
    
    /// 获取日志文件路径
    /// - Returns: 日志文件路径数组
    public func getLogFilePaths() -> [String] {
        return fileLogger?.logFileManager.sortedLogFilePaths ?? []
    }
    
    /// 获取最新的日志文件路径
    /// - Returns: 最新日志文件路径
    public func getLatestLogFilePath() -> String? {
        return fileLogger?.logFileManager.sortedLogFilePaths.first
    }
    
    /// 清理过期日志文件
    public func cleanOldLogFiles() {
        guard let fileLogger = fileLogger else { return }
        
        // 滚动当前日志文件，这会触发自动清理
        fileLogger.rollLogFile { [weak self] in
            // 获取所有日志文件路径
            let logPaths = fileLogger.logFileManager.sortedLogFilePaths
            
            // 如果文件数量超过限制，删除最旧的文件
            if let fileManager = fileLogger.logFileManager as? DDLogFileManagerDefault,
               logPaths.count > fileManager.maximumNumberOfLogFiles {
                let maxFiles = fileManager.maximumNumberOfLogFiles
                let filesToDelete = Array(logPaths.dropFirst(Int(maxFiles)))
                
                for logPath in filesToDelete {
                    do {
                        try FileManager.default.removeItem(atPath: logPath)
                        DDLogInfo("已删除过期日志文件: \(logPath)")
                    } catch {
                        DDLogError("删除日志文件失败: \(logPath), 错误: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// 设置日志级别
    /// - Parameter level: 日志级别
    public func setLogLevel(_ level: LogLevel) {
        dynamicLogLevel = level.ddLogLevel
    }
}

// MARK: - 便捷方法
/// 全局便捷方法，直接使用 Logger.shared

/// 详细日志
public func LogVerbose(_ message: String,
                       file: StaticString = #file,
                       function: StaticString = #function,
                       line: UInt = #line) {
    Logger.shared.verbose(message, file: file, function: function, line: line)
}

/// 调试日志
public func LogDebug(_ message: String,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
    Logger.shared.debug(message, file: file, function: function, line: line)
}

/// 信息日志
public func LogInfo(_ message: String,
                    file: StaticString = #file,
                    function: StaticString = #function,
                    line: UInt = #line) {
    Logger.shared.info(message, file: file, function: function, line: line)
}

/// 警告日志
public func LogWarning(_ message: String,
                       file: StaticString = #file,
                       function: StaticString = #function,
                       line: UInt = #line) {
    Logger.shared.warning(message, file: file, function: function, line: line)
}

/// 错误日志
public func LogError(_ message: String,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
    Logger.shared.error(message, file: file, function: function, line: line)
}

/// 错误日志（带错误对象）
public func LogError(_ message: String,
                     error: Error,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
    Logger.shared.error(message, error: error, file: file, function: function, line: line)
}

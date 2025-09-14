import Foundation

/// 通用防抖/节流工具：
/// - shouldPerform: 适合按钮点击等场景，首次触发立即执行，间隔内忽略（节流）
/// - perform: 便捷方法，只有在 shouldPerform 返回允许时才执行 action
final class DebounceManager {
    static let shared = DebounceManager()
    
    private let syncQueue = DispatchQueue(label: "com.repread.ready.debounce.manager")
    private var lastFireTimeByKey: [String: CFAbsoluteTime] = [:]
    
    private init() {}
    
    /// 判断是否允许在指定间隔内执行（节流：立即执行，间隔内拒绝）
    /// - Parameters:
    ///   - key: 业务唯一键（如页面+按钮标识）
    ///   - interval: 最小触发间隔（秒）
    /// - Returns: 是否允许执行
    func shouldPerform(key: String, interval: TimeInterval) -> Bool {
        let now = CFAbsoluteTimeGetCurrent()
        var allowed = false
        
        syncQueue.sync {
            let last = lastFireTimeByKey[key] ?? 0
            if now - last >= interval {
                lastFireTimeByKey[key] = now
                allowed = true
            }
        }
        
        return allowed
    }
    
    /// 便捷执行方法：仅当允许时才执行 action
    func perform(key: String, interval: TimeInterval, action: () -> Void) {
        if shouldPerform(key: key, interval: interval) {
            action()
        }
    }
}

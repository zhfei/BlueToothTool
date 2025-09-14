//
//  TaskProgressBar.swift
//  RepReady
//
//  Created by zhoufei on 2025/6/8.
//

import SnapKit
import UIKit

class TaskProgressBar: UIView {
    
    // MARK: - Properties
    
    private static var sharedWindow: UIWindow?
    static var sharedInstance: TaskProgressBar?
    
    private var progressView: UIView!
    private var backgroundView: UIView!
    
    private var currentProgress: CGFloat = 0
    private var maxProgress: CGFloat = 1
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setProgressColor(_ color: UIColor) {
        progressView.backgroundColor = color
    }
    
    private func setupViews() {
        // 背景视图 - 深色部分
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)  // 半透明白色
        backgroundView.layer.cornerRadius = 5
        backgroundView.clipsToBounds = true
        addSubview(backgroundView)
        
        // 进度视图 - 绿色部分
        progressView = UIView()
        progressView.backgroundColor = Color.greenLight  // 使用项目中定义的绿色
        progressView.layer.cornerRadius = 5
        progressView.clipsToBounds = true
        addSubview(progressView)
        
        // 设置约束
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(0)  // 初始宽度为0
        }
    }
    
    // MARK: - Public Methods
    
    /// 显示任务进度条
    /// - Parameters:
    ///   - progress: 当前进度值
    ///   - maxProgress: 最大进度值
    ///   - animated: 是否使用动画效果
    static func show(progress: CGFloat, maxProgress: CGFloat, animated: Bool = true) {
        DispatchQueue.main.async {
            // 如果窗口不存在，创建一个新窗口
            if sharedWindow == nil {
                var windowFrame: CGRect
                if #available(iOS 13.0, *) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowFrame = windowScene.coordinateSpace.bounds
                    } else {
                        windowFrame = UIScreen.main.bounds
                    }
                } else {
                    windowFrame = UIScreen.main.bounds
                }
                let window = UIWindow(frame: windowFrame)
                window.windowLevel = .statusBar + 1  // 确保显示在状态栏之上
                window.backgroundColor = .clear
                window.isUserInteractionEnabled = false  // 不接收用户交互
                
                // iOS 13 及以上需要设置 windowScene
                if #available(iOS 13.0, *) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        window.windowScene = windowScene
                    }
                }
                
                // 创建进度条实例
                let progressBar = TaskProgressBar(
                    frame: CGRect(x: 20, y: 0, width: windowFrame.width - 40, height: 10))
                window.addSubview(progressBar)
                
                // 需要在 window 显示后再获取 safeAreaInsets
                window.layoutIfNeeded()
                let top = max(window.safeAreaInsets.top, 20) + 12
                
                progressBar.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(20)
                    make.top.equalToSuperview().offset(top)
                    make.height.equalTo(10)
                }
                
                sharedWindow = window
                sharedInstance = progressBar
                
                // 确保window显示
                window.isHidden = false
                window.makeKeyAndVisible()
            }
            
            // 更新进度
            sharedInstance?.update(progress: progress, maxProgress: maxProgress, animated: animated)
        }
    }
    
    /// 更新任务进度条
    /// - Parameters:
    ///   - progress: 当前进度值
    ///   - maxProgress: 最大进度值
    ///   - animated: 是否使用动画效果
    func update(progress: CGFloat, maxProgress: CGFloat, animated: Bool = true) {
        self.currentProgress = max(0, min(progress, maxProgress))
        self.maxProgress = max(1, maxProgress)
        
        let progressRatio = self.currentProgress / self.maxProgress
        
        // 更新进度条宽度
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.progressView.snp.remakeConstraints { make in
                    make.top.bottom.left.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(progressRatio)
                }
                self.layoutIfNeeded()
            }
        } else {
            self.progressView.snp.remakeConstraints { make in
                make.top.bottom.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(progressRatio)
            }
            self.layoutIfNeeded()
        }
    }
    
    /// 隐藏任务进度条
    static func hide(animated: Bool = true) {
        DispatchQueue.main.async {
            if animated {
                UIView.animate(
                    withDuration: 0.3,
                    animations: {
                        sharedWindow?.alpha = 0
                    }
                ) { _ in
                    sharedWindow?.isHidden = true
                    sharedWindow = nil
                    sharedInstance = nil
                }
            } else {
                sharedWindow?.isHidden = true
                sharedWindow = nil
                sharedInstance = nil
            }
        }
    }
    
    /// 更新进度并在完成后隐藏
    /// - Parameters:
    ///   - progress: 当前进度值
    ///   - maxProgress: 最大进度值
    ///   - hideDelay: 完成后隐藏的延迟时间（秒）
    static func updateAndHideWhenComplete(
        progress: CGFloat, maxProgress: CGFloat, hideDelay: TimeInterval = 0.5
    ) {
        show(progress: progress, maxProgress: maxProgress)
        
        // 如果进度已完成，延迟后隐藏
        if progress >= maxProgress {
            DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay) {
                hide()
            }
        }
    }
}

// MARK: - 便捷方法
extension TaskProgressBar {
    /// 显示任务进度条（百分比形式）
    /// - Parameters:
    ///   - percent: 百分比值（0-100）
    ///   - animated: 是否使用动画效果
    static func showWithPercent(_ percent: CGFloat, animated: Bool = true) {
        show(progress: percent, maxProgress: 100, animated: animated)
    }
    
    /// 更新进度（百分比形式）并在完成后隐藏
    /// - Parameters:
    ///   - percent: 百分比值（0-100）
    ///   - hideDelay: 完成后隐藏的延迟时间（秒）
    static func updateWithPercentAndHideWhenComplete(
        _ percent: CGFloat, hideDelay: TimeInterval = 0.5
    ) {
        updateAndHideWhenComplete(progress: percent, maxProgress: 100, hideDelay: hideDelay)
    }
}

//
//  LottiePlayView.swift
//  RepReady
//
//  Created by 周飞 on 2025/8/20.
//

import UIKit
import Lottie

/// Lottie动画模型
struct LottieModel {
    /// 本地Lottie文件名（不包含.json扩展名）
    let lottieName: String?
    
    /// 远程Lottie动画URL
    let lottieUrl: URL?
    
    /// 在循环过程中播放的次数
    let playNumber: Int
    
    /// 与上一个LottieModel之间的播放时间间隔（秒）
    let interval: TimeInterval
    
    /// 初始化方法
    /// - Parameters:
    ///   - lottieName: 本地Lottie文件名，与lottieUrl二选一
    ///   - lottieUrl: 远程Lottie动画URL，与lottieName二选一
    ///   - playNumber: 播放次数，默认1
    ///   - interval: 时间间隔，默认0
    init(lottieName: String? = nil, lottieUrl: URL? = nil, playNumber: Int = 1, interval: TimeInterval = 0) {
        self.lottieName = lottieName
        self.lottieUrl = lottieUrl
        self.playNumber = max(1, playNumber) // 确保至少播放1次
        self.interval = max(0, interval) // 确保间隔不为负数
    }
    
    /// 便捷初始化方法 - 本地文件
    /// - Parameters:
    ///   - lottieName: 本地Lottie文件名
    ///   - playNumber: 播放次数，默认1
    ///   - interval: 时间间隔，默认0
    init(lottieName: String, playNumber: Int = 1, interval: TimeInterval = 0) {
        self.init(lottieName: lottieName, lottieUrl: nil, playNumber: playNumber, interval: interval)
    }
    
    /// 便捷初始化方法 - 远程URL
    /// - Parameters:
    ///   - lottieUrl: 远程Lottie动画URL
    ///   - playNumber: 播放次数，默认1
    ///   - interval: 时间间隔，默认0
    init(lottieUrl: URL, playNumber: Int = 1, interval: TimeInterval = 0) {
        self.init(lottieName: nil, lottieUrl: lottieUrl, playNumber: playNumber, interval: interval)
    }
    
    /// 获取Lottie动画的URL
    /// - Returns: 本地文件URL或远程URL
    func getLottieURL() -> URL? {
        if let lottieName = lottieName {
            guard let path = Bundle.main.path(forResource: lottieName, ofType: "json") else {
                print("LottieModel: Lottie file not found: \(lottieName)")
                return nil
            }
            return URL(fileURLWithPath: path)
        }
        return lottieUrl
    }
    
    /// 检查模型是否有效
    /// - Returns: 是否有效
    var isValid: Bool {
        return getLottieURL() != nil
    }
}

/// 通用Lottie播放视图
/// 支持本地和远程URL的Lottie动画播放
class LottiePlayView: UIView {

    // MARK: - Properties
    
    /// Lottie动画视图
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 1.0
        return view
    }()
    
    /// 动画URL（本地或远程）
    private var lottieURL: URL?
    
    /// 是否自动播放
    private var autoPlay: Bool = false
    
    /// 序列播放相关属性
    private var lottieURLs: [URL] = []
    private var currentURLIndex: Int = 0
    private var isPlayingSequence: Bool = false
    private var sequenceInterval: TimeInterval = 0.0
    private var sequenceTimer: Timer?
    
    /// LottieModel序列播放相关属性
    private var lottieModels: [LottieModel] = []
    private var currentModelIndex: Int = 0
    private var currentModelPlayCount: Int = 0
    private var isPlayingModelSequence: Bool = false
    private var modelSequenceTimer: Timer?
    
    /// 播放状态回调
    var onPlayStateChanged: ((Bool) -> Void)?
    
    /// 加载完成回调
    var onLoadCompleted: (() -> Void)?
    
    /// 加载失败回调
    var onLoadFailed: ((Error) -> Void)?
    
    /// 序列播放完成回调（一轮播放完成）
    var onSequenceCompleted: (() -> Void)?
    
    /// LottieModel序列播放完成回调（一轮播放完成）
    var onModelSequenceCompleted: (() -> Void)?
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieURL: Lottie动画URL（本地或远程）
    ///   - autoPlay: 是否自动播放，默认false
    init(frame: CGRect, lottieURL: URL, autoPlay: Bool = false) {
        self.lottieURL = lottieURL
        self.autoPlay = autoPlay
        super.init(frame: frame)
        setupUI()
        loadAnimation()
    }
    
    /// 便捷初始化方法
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieName: 本地Lottie文件名（不包含.json扩展名）
    ///   - autoPlay: 是否自动播放，默认false
    convenience init(frame: CGRect, lottieName: String, autoPlay: Bool = false) {
        guard let path = Bundle.main.path(forResource: lottieName, ofType: "json") else {
            fatalError("Lottie file not found: \(lottieName)")
        }
        let url = URL(fileURLWithPath: path)
        self.init(frame: frame, lottieURL: url, autoPlay: autoPlay)
    }
    
    /// 便捷初始化方法
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieURLString: Lottie动画URL字符串
    ///   - autoPlay: 是否自动播放，默认false
    convenience init(frame: CGRect, lottieURLString: String, autoPlay: Bool = false) {
        guard let url = URL(string: lottieURLString) else {
            fatalError("Invalid URL string: \(lottieURLString)")
        }
        self.init(frame: frame, lottieURL: url, autoPlay: autoPlay)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Animation Loading
    
    /// 加载Lottie动画
    private func loadAnimation() {
        guard let url = lottieURL else {
            let error = NSError(domain: "LottiePlayView", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Lottie URL provided"])
            onLoadFailed?(error)
            return
        }
        
        if url.scheme == "http" || url.scheme == "https" {
            // 远程URL
            loadRemoteAnimation(from: url)
        } else {
            // 本地URL
            loadLocalAnimation(from: url)
        }
    }
    
    /// 加载本地动画
    private func loadLocalAnimation(from url: URL) {
        LottieAnimation.loadedFrom(url: url) { [weak self] animation in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.animationView.animation = animation
                self.onLoadCompleted?()
                
                if self.autoPlay {
                    self.play()
                }
            }
        }
    }
    
    /// 加载远程动画
    private func loadRemoteAnimation(from url: URL) {
        // 创建URLSession任务下载动画文件
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.onLoadFailed?(error)
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "LottiePlayView", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    self.onLoadFailed?(error)
                    return
                }
                
                do {
                    let animation = try LottieAnimation.from(data: data)
                    self.animationView.animation = animation
                    self.onLoadCompleted?()
                    
                    if self.autoPlay {
                        self.play()
                    }
                } catch {
                    self.onLoadFailed?(error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Public Methods
    
    /// 播放动画
    func play() {
        guard animationView.animation != nil else {
            // 如果动画还没加载完成，等待加载完成后自动播放
            autoPlay = true
            return
        }
        
        animationView.play()
        onPlayStateChanged?(true)
    }
    
    /// 暂停动画
    func pause() {
        animationView.pause()
        onPlayStateChanged?(false)
    }
    
    /// 停止动画
    func stop() {
        animationView.stop()
        onPlayStateChanged?(false)
    }
    
    /// 设置动画速度
    /// - Parameter speed: 播放速度，1.0为正常速度
    func setAnimationSpeed(_ speed: CGFloat) {
        animationView.animationSpeed = speed
    }
    
    /// 设置循环模式
    /// - Parameter mode: 循环模式
    func setLoopMode(_ mode: LottieLoopMode) {
        animationView.loopMode = mode
    }
    
    /// 跳转到指定帧
    /// - Parameter frame: 目标帧数
    func seekToFrame(_ frame: CGFloat) {
        animationView.currentFrame = frame
    }
    
    /// 跳转到指定进度
    /// - Parameter progress: 进度值（0.0 - 1.0）
    func seekToProgress(_ progress: CGFloat) {
        animationView.currentProgress = progress
    }
    
    /// 重新加载动画
    func reload() {
        animationView.stop()
        animationView.animation = nil
        autoPlay = false
        loadAnimation()
    }
    
    /// 设置新的Lottie URL
    /// - Parameter url: 新的Lottie动画URL
    func setLottieURL(_ url: URL) {
        lottieURL = url
        reload()
    }
    
    /// 设置新的Lottie文件名
    /// - Parameter name: 本地Lottie文件名（不包含.json扩展名）
    func setLottieName(_ name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else {
            print("Lottie file not found: \(name)")
            return
        }
        let url = URL(fileURLWithPath: path)
        setLottieURL(url)
    }
    
    /// 设置新的Lottie URL字符串
    /// - Parameter urlString: Lottie动画URL字符串
    func setLottieURLString(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        setLottieURL(url)
    }
    
    // MARK: - Sequence Playback Methods
    
    /// 开始循环播放Lottie URL组
    /// - Parameters:
    ///   - urls: Lottie动画URL数组
    ///   - interval: 相邻两个动画之间的时间间隔（秒）
    ///   - autoStart: 是否立即开始播放，默认true
    func startSequencePlayback(urls: [URL], interval: TimeInterval, autoStart: Bool = true) {
        guard !urls.isEmpty else {
            print("LottiePlayView: URLs array is empty")
            return
        }
        
        // 停止当前序列播放
        stopSequencePlayback()
        
        // 设置新的序列
        lottieURLs = urls
        sequenceInterval = interval
        currentURLIndex = 0
        isPlayingSequence = true
        
        if autoStart {
            // 直接播放第一个动画，不通过playCurrentSequenceAnimation
            playAnimationAtIndex(0)
        }
    }
    
    /// 开始循环播放Lottie文件名组
    /// - Parameters:
    ///   - names: Lottie文件名数组（不包含.json扩展名）
    ///   - interval: 相邻两个动画之间的时间间隔（秒）
    ///   - autoStart: 是否立即开始播放，默认true
    func startSequencePlayback(names: [String], interval: TimeInterval, autoStart: Bool = true) {
        let urls = names.compactMap { name -> URL? in
            guard let path = Bundle.main.path(forResource: name, ofType: "json") else {
                print("LottiePlayView: Lottie file not found: \(name)")
                return nil
            }
            return URL(fileURLWithPath: path)
        }
        
        startSequencePlayback(urls: urls, interval: interval, autoStart: autoStart)
    }
    
    /// 开始循环播放Lottie URL字符串组
    /// - Parameters:
    ///   - urlStrings: Lottie动画URL字符串数组
    ///   - interval: 相邻两个动画之间的时间间隔（秒）
    ///   - autoStart: 是否立即开始播放，默认true
    func startSequencePlayback(urlStrings: [String], interval: TimeInterval, autoStart: Bool = true) {
        let urls = urlStrings.compactMap { urlString -> URL? in
            guard let url = URL(string: urlString) else {
                print("LottiePlayView: Invalid URL string: \(urlString)")
                return nil
            }
            return url
        }
        
        startSequencePlayback(urls: urls, interval: interval, autoStart: autoStart)
    }
    
    /// 停止序列播放
    func stopSequencePlayback() {
        isPlayingSequence = false
        sequenceTimer?.invalidate()
        sequenceTimer = nil
        stop()
        
        // 重置序列状态
        lottieURLs.removeAll()
        currentURLIndex = 0
        sequenceInterval = 0.0
    }
    
    /// 暂停序列播放
    func pauseSequencePlayback() {
        isPlayingSequence = false
        sequenceTimer?.invalidate()
        sequenceTimer = nil
        pause()
    }
    
    /// 恢复序列播放
    func resumeSequencePlayback() {
        guard !lottieURLs.isEmpty else { return }
        
        isPlayingSequence = true
        playCurrentSequenceAnimation()
    }
    
    /// 跳转到序列中的指定动画
    /// - Parameter index: 目标动画索引
    func seekToSequenceIndex(_ index: Int) {
        guard index >= 0 && index < lottieURLs.count else {
            print("LottiePlayView: Invalid sequence index: \(index)")
            return
        }
        
        currentURLIndex = index
        playCurrentSequenceAnimation()
    }
    
    /// 获取当前序列播放状态
    /// - Returns: 序列播放状态信息
    func getSequencePlaybackStatus() -> (isPlaying: Bool, currentIndex: Int, totalCount: Int, interval: TimeInterval) {
        return (isPlayingSequence, currentURLIndex, lottieURLs.count, sequenceInterval)
    }
    
    // MARK: - Convenience Methods
    
    /// 播放一次动画（不循环）
    func playOnce() {
        setLoopMode(.playOnce)
        play()
    }
    
    /// 播放指定次数
    /// - Parameter count: 播放次数
    func playCount(_ count: Int) {
        setLoopMode(.repeat(Float(count)))
        play()
    }
    
    /// 播放并设置完成回调
    /// - Parameter completion: 播放完成回调
    func playWithCompletion(_ completion: @escaping () -> Void) {
        // 保存原始循环模式
        let originalLoopMode = animationView.loopMode
        
        // 设置为播放一次
        setLoopMode(.playOnce)
        
        // 播放动画
        play()
        
        // 监听播放完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.checkAnimationCompletion(originalLoopMode: originalLoopMode, completion: completion)
        }
    }
    
    /// 检查动画是否播放完成
    private func checkAnimationCompletion(originalLoopMode: LottieLoopMode, completion: @escaping () -> Void) {
        guard animationView.animation != nil else { return }
        
        if animationView.isAnimationPlaying {
            // 如果还在播放，继续检查
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkAnimationCompletion(originalLoopMode: originalLoopMode, completion: completion)
            }
        } else {
            // 播放完成，恢复原始循环模式并执行回调
            setLoopMode(originalLoopMode)
            completion()
        }
    }
    
    /// 播放当前序列动画
    private func playCurrentSequenceAnimation() {
        guard isPlayingSequence && !lottieURLs.isEmpty else { return }
        guard currentURLIndex < lottieURLs.count else { return }
        
        playAnimationAtIndex(currentURLIndex)
    }
    
    /// 播放指定索引的动画
    private func playAnimationAtIndex(_ index: Int) {
        guard index >= 0 && index < lottieURLs.count else { return }
        
        let targetURL = lottieURLs[index]
        print("LottiePlayView: 开始播放动画索引: \(index), URL: \(targetURL.lastPathComponent)")
        
        // 设置循环模式为播放一次
        setLoopMode(.playOnce)
        
        // 加载并播放目标动画
        if targetURL.scheme == "http" || targetURL.scheme == "https" {
            loadRemoteAnimationForSequence(from: targetURL)
        } else {
            loadLocalAnimationForSequence(from: targetURL)
        }
    }
    
    /// 为序列播放加载本地动画
    private func loadLocalAnimationForSequence(from url: URL) {
        LottieAnimation.loadedFrom(url: url) { [weak self] animation in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.animationView.animation = animation
                self.playCurrentSequenceAnimationWithCompletion()
            }
        }
    }
    
    /// 为序列播放加载远程动画
    private func loadRemoteAnimationForSequence(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("LottiePlayView: Failed to load remote animation: \(error)")
                    self.moveToNextSequenceAnimation()
                    return
                }
                
                guard let data = data else {
                    print("LottiePlayView: No data received for remote animation")
                    self.moveToNextSequenceAnimation()
                    return
                }
                
                do {
                    let animation = try LottieAnimation.from(data: data)
                    self.animationView.animation = animation
                    self.playCurrentSequenceAnimationWithCompletion()
                } catch {
                    print("LottiePlayView: Failed to parse remote animation: \(error)")
                    self.moveToNextSequenceAnimation()
                }
            }
        }
        task.resume()
    }
    
    /// 播放当前序列动画并设置完成回调
    private func playCurrentSequenceAnimationWithCompletion() {
        // 播放当前动画
        play()
        
        // 监听播放完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.checkSequenceAnimationCompletion()
        }
    }
    
    /// 检查序列动画是否播放完成
    private func checkSequenceAnimationCompletion() {
        guard isPlayingSequence && animationView.animation != nil else { return }
        
        if animationView.isAnimationPlaying {
            // 如果还在播放，继续检查
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkSequenceAnimationCompletion()
            }
        } else {
            // 播放完成，延迟指定时间后播放下一个动画
            DispatchQueue.main.asyncAfter(deadline: .now() + sequenceInterval) { [weak self] in
                self?.moveToNextSequenceAnimation()
            }
        }
    }
    
    /// 移动到下一个序列动画
    private func moveToNextSequenceAnimation() {
        guard isPlayingSequence else { return }
        
        // 计算下一个索引
        let nextIndex = currentURLIndex + 1
        
        // 如果到达末尾，循环到第一个
        if nextIndex >= lottieURLs.count {
            currentURLIndex = 0
            // 一轮播放完成，调用回调
            onSequenceCompleted?()
            print("LottiePlayView: 序列播放完成一轮，重新开始")
        } else {
            currentURLIndex = nextIndex
        }
        
        print("LottiePlayView: 切换到动画索引: \(currentURLIndex)")
        
        // 播放下一个动画
        playAnimationAtIndex(currentURLIndex)
    }
    
    // MARK: - LottieModel Sequence Playback Methods
    
    /// 开始循环播放LottieModel列表
    /// - Parameters:
    ///   - models: LottieModel数组
    ///   - autoStart: 是否立即开始播放，默认true
    func startModelSequencePlayback(models: [LottieModel], autoStart: Bool = true) {
        guard !models.isEmpty else {
            print("LottiePlayView: LottieModel array is empty")
            return
        }
        
        // 过滤掉无效的模型
        let validModels = models.filter { $0.isValid }
        guard !validModels.isEmpty else {
            print("LottiePlayView: No valid LottieModel found")
            return
        }
        
        // 停止当前序列播放
        stopModelSequencePlayback()
        
        // 设置新的序列
        lottieModels = validModels
        currentModelIndex = 0
        currentModelPlayCount = 0
        isPlayingModelSequence = true
        
        if autoStart {
            playCurrentModelAnimation()
        }
    }
    
    /// 停止LottieModel序列播放
    func stopModelSequencePlayback() {
        isPlayingModelSequence = false
        modelSequenceTimer?.invalidate()
        modelSequenceTimer = nil
        stop()
        
        // 重置序列状态
        lottieModels.removeAll()
        currentModelIndex = 0
        currentModelPlayCount = 0
    }
    
    /// 暂停LottieModel序列播放
    func pauseModelSequencePlayback() {
        isPlayingModelSequence = false
        modelSequenceTimer?.invalidate()
        modelSequenceTimer = nil
        pause()
    }
    
    /// 恢复LottieModel序列播放
    func resumeModelSequencePlayback() {
        guard !lottieModels.isEmpty else { return }
        
        isPlayingModelSequence = true
        playCurrentModelAnimation()
    }
    
    /// 跳转到LottieModel序列中的指定动画
    /// - Parameter index: 目标动画索引
    func seekToModelSequenceIndex(_ index: Int) {
        guard index >= 0 && index < lottieModels.count else {
            print("LottiePlayView: Invalid model sequence index: \(index)")
            return
        }
        
        currentModelIndex = index
        currentModelPlayCount = 0
        playCurrentModelAnimation()
    }
    
    /// 获取当前LottieModel序列播放状态
    /// - Returns: 序列播放状态信息
    func getModelSequencePlaybackStatus() -> (isPlaying: Bool, currentIndex: Int, totalCount: Int, currentPlayCount: Int, totalPlayCount: Int) {
        let totalPlayCount = lottieModels.reduce(0) { $0 + $1.playNumber }
        return (isPlayingModelSequence, currentModelIndex, lottieModels.count, currentModelPlayCount, totalPlayCount)
    }
    
    /// 播放当前LottieModel动画
    private func playCurrentModelAnimation() {
        guard isPlayingModelSequence && !lottieModels.isEmpty else { return }
        guard currentModelIndex < lottieModels.count else { return }
        
        let currentModel = lottieModels[currentModelIndex]
        guard let targetURL = currentModel.getLottieURL() else {
            print("LottiePlayView: Invalid LottieModel at index: \(currentModelIndex)")
            moveToNextModelAnimation()
            return
        }
        
//        print("LottiePlayView: 开始播放LottieModel索引: \(currentModelIndex), 播放次数: \(currentModelPlayCount + 1)/\(currentModel.playNumber), URL: \(targetURL.lastPathComponent)")
        
        // 设置循环模式为播放一次
        setLoopMode(.playOnce)
        
        // 加载并播放目标动画
        if targetURL.scheme == "http" || targetURL.scheme == "https" {
            loadRemoteAnimationForModelSequence(from: targetURL)
        } else {
            loadLocalAnimationForModelSequence(from: targetURL)
        }
    }
    
    /// 为LottieModel序列播放加载本地动画
    private func loadLocalAnimationForModelSequence(from url: URL) {
        LottieAnimation.loadedFrom(url: url) { [weak self] animation in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.animationView.animation = animation
                self.playCurrentModelAnimationWithCompletion()
            }
        }
    }
    
    /// 为LottieModel序列播放加载远程动画
    private func loadRemoteAnimationForModelSequence(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("LottiePlayView: Failed to load remote animation for model sequence: \(error)")
                    self.moveToNextModelAnimation()
                    return
                }
                
                guard let data = data else {
                    print("LottiePlayView: No data received for remote animation in model sequence")
                    self.moveToNextModelAnimation()
                    return
                }
                
                do {
                    let animation = try LottieAnimation.from(data: data)
                    self.animationView.animation = animation
                    self.playCurrentModelAnimationWithCompletion()
                } catch {
                    print("LottiePlayView: Failed to parse remote animation for model sequence: \(error)")
                    self.moveToNextModelAnimation()
                }
            }
        }
        task.resume()
    }
    
    /// 播放当前LottieModel动画并设置完成回调
    private func playCurrentModelAnimationWithCompletion() {
        // 直接使用animationView.play的回调方式，而不是调用play()方法
        animationView.play { [weak self] finished in
            guard let self = self, finished else { return }
            // 动画播放完成，处理播放次数逻辑
            self.handleModelAnimationCompletion()
        }
        
        // 通知播放状态改变
        onPlayStateChanged?(true)
    }
    
    /// 检查LottieModel动画是否播放完成（已废弃，使用动画完成回调替代）
    private func checkModelAnimationCompletion() {
        // 这个方法不再使用，保留是为了兼容性
    }
    
    /// 处理LottieModel动画播放完成后的逻辑
    private func handleModelAnimationCompletion() {
        guard isPlayingModelSequence else { return }
        
        let currentModel = lottieModels[currentModelIndex]
        currentModelPlayCount += 1
        
//        print("LottiePlayView: LottieModel索引: \(currentModelIndex), 播放次数: \(currentModelPlayCount)/\(currentModel.playNumber)")
        
        if currentModelPlayCount >= currentModel.playNumber {
            // 当前模型播放次数已达到，移动到下一个
            moveToNextModelAnimation()
        } else {
            // 当前模型还需要继续播放，延迟后重新播放
            // 需要重新设置播放完成回调，因为play()方法没有回调
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.playCurrentModelAnimationWithCompletion()
            }
        }
    }
    
    /// 移动到下一个LottieModel动画
    private func moveToNextModelAnimation() {
        guard isPlayingModelSequence else { return }
        
        let currentModel = lottieModels[currentModelIndex]
        let nextIndex = currentModelIndex + 1
        
        // 如果到达末尾，循环到第一个
        if nextIndex >= lottieModels.count {
            currentModelIndex = 0
            currentModelPlayCount = 0
            // 一轮播放完成，调用回调
            onModelSequenceCompleted?()
            print("LottiePlayView: LottieModel序列播放完成一轮，重新开始")
        } else {
            currentModelIndex = nextIndex
            currentModelPlayCount = 0
        }
        
        print("LottiePlayView: 切换到LottieModel索引: \(currentModelIndex)")
        
        // 延迟指定时间间隔后播放下一个动画
        let nextModel = lottieModels[currentModelIndex]
        DispatchQueue.main.asyncAfter(deadline: .now() + nextModel.interval) { [weak self] in
            self?.playCurrentModelAnimation()
        }
    }
}

// MARK: - Convenience Extensions

extension LottiePlayView {
    
    /// 创建并播放本地Lottie动画
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieName: 本地Lottie文件名
    ///   - autoPlay: 是否自动播放
    /// - Returns: 配置好的LottiePlayView实例
    static func createAndPlay(frame: CGRect, lottieName: String, autoPlay: Bool = true) -> LottiePlayView {
        let view = LottiePlayView(frame: frame, lottieName: lottieName, autoPlay: autoPlay)
        return view
    }
    
    /// 创建并播放远程Lottie动画
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieURLString: 远程Lottie动画URL字符串
    ///   - autoPlay: 是否自动播放
    /// - Returns: 配置好的LottiePlayView实例
    static func createAndPlay(frame: CGRect, lottieURLString: String, autoPlay: Bool = true) -> LottiePlayView {
        let view = LottiePlayView(frame: frame, lottieURLString: lottieURLString, autoPlay: autoPlay)
        return view
    }
    
    /// 创建并开始序列播放本地Lottie动画
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieNames: 本地Lottie文件名数组
    ///   - interval: 相邻两个动画之间的时间间隔（秒）
    /// - Returns: 配置好的LottiePlayView实例
    static func createAndStartSequence(frame: CGRect, lottieNames: [String], interval: TimeInterval) -> LottiePlayView {
        // 使用第一个文件名创建视图，然后开始序列播放
        guard let firstPath = Bundle.main.path(forResource: lottieNames.first ?? "", ofType: "json") else {
            fatalError("First Lottie file not found: \(lottieNames.first ?? "")")
        }
        let firstURL = URL(fileURLWithPath: firstPath)
        let view = LottiePlayView(frame: frame, lottieURL: firstURL, autoPlay: false)
        view.startSequencePlayback(names: lottieNames, interval: interval)
        return view
    }
    
    /// 创建并开始序列播放远程Lottie动画
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieURLStrings: 远程Lottie动画URL字符串数组
    ///   - interval: 相邻两个动画之间的时间间隔（秒）
    /// - Returns: 配置好的LottiePlayView实例
    static func createAndStartSequence(frame: CGRect, lottieURLStrings: [String], interval: TimeInterval) -> LottiePlayView {
        // 使用第一个URL创建视图，然后开始序列播放
        guard let firstURL = URL(string: lottieURLStrings.first ?? "") else {
            fatalError("Invalid first URL string: \(lottieURLStrings.first ?? "")")
        }
        let view = LottiePlayView(frame: frame, lottieURL: firstURL, autoPlay: false)
        view.startSequencePlayback(urlStrings: lottieURLStrings, interval: interval)
        return view
    }
    
    /// 创建并开始LottieModel序列播放
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - models: LottieModel数组
    /// - Returns: 配置好的LottiePlayView实例
    static func createAndStartModelSequence(frame: CGRect, models: [LottieModel]) -> LottiePlayView {
        // 使用第一个有效的模型创建视图，然后开始序列播放
        guard let firstValidModel = models.first(where: { $0.isValid }),
              let firstURL = firstValidModel.getLottieURL() else {
            fatalError("No valid LottieModel found in the array")
        }
        
        let view = LottiePlayView(frame: frame, lottieURL: firstURL, autoPlay: false)
        view.startModelSequencePlayback(models: models)
        return view
    }
    
    /// 创建并开始LottieModel序列播放（本地文件版本）
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieNames: 本地Lottie文件名数组
    ///   - playNumbers: 对应的播放次数数组，如果为nil则每个都播放1次
    ///   - intervals: 对应的时间间隔数组，如果为nil则每个间隔都为0
    /// - Returns: 配置好的LottiePlayView实例
    static func createAndStartModelSequence(frame: CGRect, lottieNames: [String], playNumbers: [Int]? = nil, intervals: [TimeInterval]? = nil) -> LottiePlayView {
        let models = lottieNames.enumerated().map { index, name in
            let playNumber = (playNumbers != nil && index < playNumbers!.count) ? playNumbers![index] : 1
            let interval = (intervals != nil && index < intervals!.count) ? intervals![index] : 0
            return LottieModel(lottieName: name, playNumber: playNumber, interval: interval)
        }
        
        return createAndStartModelSequence(frame: frame, models: models)
    }
    
    /// 创建并开始LottieModel序列播放（远程URL版本）
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - lottieURLs: 远程Lottie动画URL数组
    ///   - playNumbers: 对应的播放次数数组，如果为nil则每个都播放1次
    ///   - intervals: 对应的时间间隔数组，如果为nil则每个间隔都为0
    /// - Returns: 配置好的LottiePlayView实例
    static func createAndStartModelSequence(frame: CGRect, lottieURLs: [URL], playNumbers: [Int]? = nil, intervals: [TimeInterval]? = nil) -> LottiePlayView {
        let models = lottieURLs.enumerated().map { index, url in
            let playNumber = (playNumbers != nil && index < playNumbers!.count) ? playNumbers![index] : 1
            let interval = (intervals != nil && index < intervals!.count) ? intervals![index] : 0
            return LottieModel(lottieUrl: url, playNumber: playNumber, interval: interval)
        }
        
        return createAndStartModelSequence(frame: frame, models: models)
    }
    
    // MARK: - Splash Screen Animation
    
    /// 在app的window上全屏播放开屏动效
    /// - Parameters:
    ///   - lottieName: 本地Lottie文件名（不包含.json扩展名）
    ///   - backgroundColor: 背景颜色，默认透明
    ///   - completion: 播放完成后的回调
    /// - Returns: 创建的开屏动效视图，可用于提前移除
    @discardableResult
    static func showSplashAnimation(
        lottieName: String,
        backgroundColor: UIColor = .clear,
        completion: (() -> Void)? = nil
    ) -> LottiePlayView? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("LottiePlayView: 无法获取主window")
            completion?()
            return nil
        }
        
        // 创建全屏视图
        let splashView = LottiePlayView(frame: window.bounds, lottieName: lottieName, autoPlay: false)
        splashView.backgroundColor = backgroundColor
        
        // 设置动画播放一次完成后自动消失
        splashView.setLoopMode(.playOnce)
        
        // 兜底超时移除，防止异常情况下不消失
        let fallbackTimeout: TimeInterval = 6.0
        var didFinishOrTimeout = false
        let removeSplash: () -> Void = {
            guard !didFinishOrTimeout else { return }
            didFinishOrTimeout = true
            UIView.animate(withDuration: 0.3, animations: {
                splashView.alpha = 0.0
            }) { _ in
                splashView.removeFromSuperview()
                completion?()
            }
        }
        let timeoutWorkItem = DispatchWorkItem(block: removeSplash)
        DispatchQueue.main.asyncAfter(deadline: .now() + fallbackTimeout, execute: timeoutWorkItem)
        
        // 加载完成：播放并在播放完成后移除
        splashView.onLoadCompleted = {
            splashView.playWithCompletion {
                timeoutWorkItem.cancel()
                removeSplash()
            }
        }
        
        // 加载失败：直接移除
        splashView.onLoadFailed = { _ in
            timeoutWorkItem.cancel()
            removeSplash()
        }
        
        // 添加到window的最上层
        window.addSubview(splashView)
        window.bringSubviewToFront(splashView)
        
        return splashView
    }
    
    /// 在app的window上全屏播放开屏动效（使用URL）
    /// - Parameters:
    ///   - lottieURL: Lottie动画URL（本地或远程）
    ///   - backgroundColor: 背景颜色，默认透明
    ///   - completion: 播放完成后的回调
    /// - Returns: 创建的开屏动效视图，可用于提前移除
    @discardableResult
    static func showSplashAnimation(
        lottieURL: URL,
        backgroundColor: UIColor = .clear,
        completion: (() -> Void)? = nil
    ) -> LottiePlayView? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("LottiePlayView: 无法获取主window")
            completion?()
            return nil
        }
        
        // 创建全屏视图
        let splashView = LottiePlayView(frame: window.bounds, lottieURL: lottieURL, autoPlay: false)
        splashView.backgroundColor = backgroundColor
        
        // 设置动画播放一次完成后自动消失
        splashView.setLoopMode(.playOnce)
        
        // 兜底超时移除，防止异常情况下不消失
        let fallbackTimeoutURL: TimeInterval = 6.0
        var didFinishOrTimeoutURL = false
        let removeSplashURL: () -> Void = {
            guard !didFinishOrTimeoutURL else { return }
            didFinishOrTimeoutURL = true
            UIView.animate(withDuration: 0.3, animations: {
                splashView.alpha = 0.0
            }) { _ in
                splashView.removeFromSuperview()
                completion?()
            }
        }
        let timeoutWorkItemURL = DispatchWorkItem(block: removeSplashURL)
        DispatchQueue.main.asyncAfter(deadline: .now() + fallbackTimeoutURL, execute: timeoutWorkItemURL)
        
        // 加载完成：播放并在播放完成后移除
        splashView.onLoadCompleted = {
            splashView.playWithCompletion {
                timeoutWorkItemURL.cancel()
                removeSplashURL()
            }
        }
        
        // 加载失败：直接移除
        splashView.onLoadFailed = { _ in
            timeoutWorkItemURL.cancel()
            removeSplashURL()
        }
        
        // 添加到window的最上层
        window.addSubview(splashView)
        window.bringSubviewToFront(splashView)
        
        return splashView
    }
    
    /// 在app的window上全屏播放开屏动效（使用URL字符串）
    /// - Parameters:
    ///   - lottieURLString: Lottie动画URL字符串
    ///   - backgroundColor: 背景颜色，默认透明
    ///   - completion: 播放完成后的回调
    /// - Returns: 创建的开屏动效视图，可用于提前移除
    @discardableResult
    static func showSplashAnimation(
        lottieURLString: String,
        backgroundColor: UIColor = .clear,
        completion: (() -> Void)? = nil
    ) -> LottiePlayView? {
        guard let url = URL(string: lottieURLString) else {
            print("LottiePlayView: 无效的URL字符串: \(lottieURLString)")
            completion?()
            return nil
        }
        
        return showSplashAnimation(lottieURL: url, backgroundColor: backgroundColor, completion: completion)
    }
    
    /// 移除当前显示的开屏动效
    /// - Parameter animated: 是否使用动画效果移除，默认true
    static func hideSplashAnimation(animated: Bool = true) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // 查找并移除开屏动效视图
        for subview in window.subviews.reversed() {
            if let splashView = subview as? LottiePlayView {
                if animated {
                    UIView.animate(withDuration: 0.3, animations: {
                        splashView.alpha = 0.0
                    }) { _ in
                        splashView.removeFromSuperview()
                    }
                } else {
                    splashView.removeFromSuperview()
                }
                break
            }
        }
    }
}

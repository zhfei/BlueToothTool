//
//  MFIDeviceConnectDetailViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/10.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import ExternalAccessory
import BlueToothTool

class MFIDeviceConnectDetailViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    var device: MFIDeviceModel?
    var session: EASession?
    var protocolString: String?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Color.backgroundGray
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.backgroundGray
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        openSessionStreams()
        updateSessionInfo()
    }
    
    // MARK: - Session Management
    
    private func openSessionStreams() {
        guard let session = session else { return }
        
        // 打开输入流
        if let inputStream = session.inputStream {
            inputStream.delegate = self
            inputStream.schedule(in: RunLoop.current, forMode: .default)
            inputStream.open()
        }
        
        // 打开输出流
        if let outputStream = session.outputStream {
            outputStream.delegate = self
            outputStream.schedule(in: RunLoop.current, forMode: .default)
            outputStream.open()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 关闭会话
        session?.inputStream?.close()
        session?.outputStream?.close()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "MFI会话详情"
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func updateSessionInfo() {
        guard let device = device, let session = session, let protocolString = protocolString else {
            return
        }
        
        // 清空之前的内容
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var lastView: UIView?
        
        // 设备信息
        let deviceInfoSection = createSectionView(title: "设备信息")
        contentView.addSubview(deviceInfoSection)
        deviceInfoSection.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview()
        }
        lastView = deviceInfoSection
        
        // 设备名称
        let nameItem = createInfoItem(title: "设备名称", value: device.name)
        contentView.addSubview(nameItem)
        nameItem.snp.makeConstraints { make in
            make.top.equalTo(deviceInfoSection.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        lastView = nameItem
        
        // 制造商
        let manufacturerItem = createInfoItem(title: "制造商", value: device.manufacturer)
        contentView.addSubview(manufacturerItem)
        manufacturerItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = manufacturerItem
        
        // 连接ID
        let connectionIDItem = createInfoItem(title: "连接ID", value: "\(device.connectionID)")
        contentView.addSubview(connectionIDItem)
        connectionIDItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = connectionIDItem
        
        // 会话信息
        let sessionInfoSection = createSectionView(title: "会话信息")
        contentView.addSubview(sessionInfoSection)
        sessionInfoSection.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
        }
        lastView = sessionInfoSection
        
        // 协议字符串
        let protocolItem = createInfoItem(title: "协议", value: protocolString)
        contentView.addSubview(protocolItem)
        protocolItem.snp.makeConstraints { make in
            make.top.equalTo(sessionInfoSection.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        lastView = protocolItem
        
        // 输入流状态
        let inputStreamStatus = session.inputStream?.streamStatus.rawValue ?? 9999
        let inputStreamStatusText = streamStatusString(inputStreamStatus)
        let inputStreamItem = createInfoItem(title: "输入流状态", value: inputStreamStatusText)
        contentView.addSubview(inputStreamItem)
        inputStreamItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = inputStreamItem
        
        // 输出流状态
        let outputStreamStatus = session.outputStream?.streamStatus.rawValue ?? 9999
        let outputStreamStatusText = streamStatusString(outputStreamStatus)
        let outputStreamItem = createInfoItem(title: "输出流状态", value: outputStreamStatusText)
        contentView.addSubview(outputStreamItem)
        outputStreamItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = outputStreamItem
        
        // 输入流是否打开
        let inputStreamOpenItem = createInfoItem(
            title: "输入流已打开",
            value: (session.inputStream?.streamStatus == .open) ? "是" : "否"
        )
        contentView.addSubview(inputStreamOpenItem)
        inputStreamOpenItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = inputStreamOpenItem
        
        // 输出流是否打开
        let outputStreamOpenItem = createInfoItem(
            title: "输出流已打开",
            value: (session.outputStream?.streamStatus == .open) ? "是" : "否"
        )
        contentView.addSubview(outputStreamOpenItem)
        outputStreamOpenItem.snp.makeConstraints { make in
            make.top.equalTo(lastView!.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        lastView = outputStreamOpenItem
        
        // 设置 contentView 的底部约束
        if let lastView = lastView {
            lastView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-16)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createSectionView(title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = Color.white
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = Color.primaryText
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        return containerView
    }
    
    private func createInfoItem(title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = Color.white
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = Color.grayText
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = Color.primaryText
        valueLabel.numberOfLines = 0
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }
        
        containerView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        // 添加分隔线
        let separator = UIView()
        separator.backgroundColor = Color.seperatorLine
        containerView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        return containerView
    }
    
    private func streamStatusString(_ status: UInt) -> String {
        guard let streamStatus = Stream.Status(rawValue: status) else {
            return "未知"
        }
        
        switch streamStatus {
        case .notOpen:
            return "未打开"
        case .opening:
            return "打开中"
        case .open:
            return "已打开"
        case .reading:
            return "读取中"
        case .writing:
            return "写入中"
        case .atEnd:
            return "已结束"
        case .closed:
            return "已关闭"
        case .error:
            return "错误"
        @unknown default:
            return "未知"
        }
    }
}

// MARK: - StreamDelegate
extension MFIDeviceConnectDetailViewController: StreamDelegate {
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        DispatchQueue.main.async { [weak self] in
            self?.updateSessionInfo()
        }
        
        switch eventCode {
        case .openCompleted:
            print("流已打开")
        case .hasBytesAvailable:
            print("有数据可读")
            if let inputStream = aStream as? InputStream {
                self.handleInputStream(inputStream)
            }
        case .hasSpaceAvailable:
            print("有空间可写")
        case .errorOccurred:
            print("流错误: \(aStream.streamError?.localizedDescription ?? "未知错误")")
        case .endEncountered:
            print("流已结束")
        default:
            break
        }
    }
    
    private func handleInputStream(_ inputStream: InputStream) {
        var buffer = [UInt8](repeating: 0, count: 1024)
        let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
        
        if bytesRead > 0 {
            let data = Data(buffer.prefix(bytesRead))
            let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            print("收到数据: \(hexString)")
        }
    }
}

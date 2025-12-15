//
//  DataPackageViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/9/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool
import CoreBluetooth
import DZNEmptyDataSet
import MJRefresh

class CMDDebugViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    private let bleManager = BLEManager.shared
    private let mfiManager = MFIManager.shared
    
    /// 已建立 BLE 连接的设备列表
    private var connectedBLEDevices: [BLEDeviceModel] = []
    
    /// 已建立 MFI 连接的设备列表
    private var connectedMFIDevices: [MFIDeviceModel] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Color.backgroundGray
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupManagers()
        refreshDeviceList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDeviceList()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "CMD调试"
        
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BLEDeviceCell.self, forCellReuseIdentifier: "BLEDeviceCell")
        tableView.register(MFIDeviceCell.self, forCellReuseIdentifier: "MFIDeviceCell")
        
        // 配置 DZNEmptyDataSet
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        // 配置 MJRefresh 下拉刷新
        let header = MJRefreshNormalHeader { [weak self] in
            self?.refreshDeviceList()
        }
        header.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
    }
    
    private func setupManagers() {
        // BLE 设备连接成功回调
        bleManager.onDeviceConnected = { [weak self] peripheral in
            guard let self = self else { return }
            
            // 从 BLEManager 的设备列表中查找对应的设备
            if let device = self.bleManager.devices.first(where: { $0.peripheral?.identifier == peripheral.identifier }) {
                // 检查是否已存在，避免重复添加
                if !self.connectedBLEDevices.contains(where: { $0.identifier == device.identifier }) {
                    self.connectedBLEDevices.append(device)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        // MFI 设备发现/更新回调
        mfiManager.onDeviceDiscovered = { [weak self] device in
            guard let self = self else { return }
            self.updateMFIDeviceList()
        }
        
        mfiManager.onDeviceUpdated = { [weak self] device in
            guard let self = self else { return }
            self.updateMFIDeviceList()
        }
        
        mfiManager.onDeviceDisconnected = { [weak self] device in
            guard let self = self else { return }
            self.updateMFIDeviceList()
        }
    }
    
    // MARK: - Data Management
    
    private func refreshDeviceList() {
        // 刷新 BLE 设备列表（从已连接的 peripheral 中获取）
        updateBLEDeviceList()
        
        // 刷新 MFI 设备列表
        updateMFIDeviceList()
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            // 结束下拉刷新动画
            self?.tableView.mj_header?.endRefreshing()
        }
    }
    
    private func updateBLEDeviceList() {
        // 从 BLEManager 的设备列表中筛选已连接的设备
        let allDevices = bleManager.devices
        let currentlyConnected = allDevices.filter { device in
            // 检查 peripheral 是否存在且状态为已连接
            if let peripheral = device.peripheral {
                return peripheral.state == .connected
            }
            return false
        }
        
        // 更新列表，移除已断开的设备，添加新连接的设备
        connectedBLEDevices = currentlyConnected
    }
    
    private func updateMFIDeviceList() {
        // 从 MFIManager 的设备列表中筛选已连接的设备
        let allDevices = mfiManager.devices
        let currentlyConnected = allDevices.filter { $0.isConnected }
        
        // 更新列表
        connectedMFIDevices = currentlyConnected
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension CMDDebugViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // BLE 设备
            return connectedBLEDevices.count
        case 1: // MFI 设备
            return connectedMFIDevices.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // BLE 设备
            let cell = tableView.dequeueReusableCell(withIdentifier: "BLEDeviceCell", for: indexPath) as! BLEDeviceCell
            let device = connectedBLEDevices[indexPath.row]
            cell.configure(with: device)
            return cell
            
        case 1: // MFI 设备
            let cell = tableView.dequeueReusableCell(withIdentifier: "MFIDeviceCell", for: indexPath) as! MFIDeviceCell
            let device = connectedMFIDevices[indexPath.row]
            cell.configure(with: device)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "BLE 设备 (\(connectedBLEDevices.count))"
        case 1:
            return "MFI 设备 (\(connectedMFIDevices.count))"
        default:
            return nil
        }
    }
}

// MARK: - UITableViewDelegate

extension CMDDebugViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // BLE 设备
            let device = connectedBLEDevices[indexPath.row]
            let detailVC = DeviceDetailViewController()
            detailVC.device = device
            PageManager.pushViewController(detailVC, animated: true)
            
        case 1: // MFI 设备
            let device = connectedMFIDevices[indexPath.row]
            let detailVC = CMDMFIDebugDetailViewController()
            detailVC.mfiDevice = device
            PageManager.pushViewController(detailVC, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - DZNEmptyDataSetSource & DZNEmptyDataSetDelegate

extension CMDDebugViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "暂无已连接设备"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor.gray
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "请先连接 BLE 或 MFI 设备"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.lightGray
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        // 当两个 section 的总行数为 0 时显示空状态
        return connectedBLEDevices.count + connectedMFIDevices.count == 0
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        // 点击空状态时触发刷新
        refreshDeviceList()
    }
}

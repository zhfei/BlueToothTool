//
//  DeviceViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/9/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool

class DeviceViewController: BlueToothBaseTableViewController {
    
    // MARK: - Properties
    
    private let bleManager = BLEManager.shared
    private var allDevices: [BLEDeviceModel] = []
    private var filteredDevices: [BLEDeviceModel] = []

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allDevices.removeAll()
        filteredDevices.removeAll()
        
        setupBLEManager()
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    // MARK: - Setup
    
    override func setupNavigationBarStyle() {
        title = "BLE设备"
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        // 设置搜索栏占位符
        searchBar.placeholder = "搜索设备名称或UUID"
    }
    
    override func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BLEDeviceCell.self, forCellReuseIdentifier: "BLEDeviceCell")
    }
    
    private func setupBLEManager() {
        
        //创建一个定时器，每3s调用一次方法self?.updateDeviceList()，刷新搜索到的设备列表
        startRefreshTimer()
        
        // 设置设备发现回调
        bleManager.onDeviceDiscovered = { [weak self] device in
            
        }
        
        // 设置设备更新回调
        bleManager.onDeviceUpdated = { [weak self] device in
            
        }
        
        bleManager.onStopScan = { [weak self] in
            self?.updateDeviceList()
            self?.hideActivity()
        }
        
        // 设置蓝牙状态变化回调
        bleManager.onBluetoothStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                if state == .poweredOn {
                    self?.startScanning()
                } else {
                    self?.stopScanning()
                }
            }
        }
    }
    
    // MARK: - Abstract Methods Implementation
    
    override func numberOfDevices() -> Int {
        return filteredDevices.count
    }
    
    override func filterDevices() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            filteredDevices = allDevices
            return
        }
        
        let lowercasedSearchText = searchText.lowercased()
        filteredDevices = allDevices.filter { device in
            device.name.lowercased().contains(lowercasedSearchText) ||
            device.identifier.lowercased().contains(lowercasedSearchText)
        }
    }
    
    override func performRefresh() {
        startScanning()
    }
    
    override func emptyStateTitle() -> String {
        return "暂无BLE设备"
    }
    
    // MARK: - BLE Scanning
    
    private func startScanning() {
        self.showActivity()
        // 停止当前扫描
        stopScanning()
        
        // 清空设备列表
        bleManager.clearDevices()
        
        // 重新开始扫描
        bleManager.startScanning()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {[weak self] in
            self?.hideActivity()
            // 结束下拉刷新动画
            self?.tableView.mj_header?.endRefreshing()
        })
    }
    
    private func stopScanning() {
        bleManager.stopScanning()
    }
    
    
    // MARK: - Data Management
    
    override func updateDeviceList() {
        allDevices = bleManager.devices
        filterDevices()
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension DeviceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLEDeviceCell", for: indexPath) as! BLEDeviceCell
        let device = filteredDevices[indexPath.row]
        cell.configure(with: device)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DeviceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = filteredDevices[indexPath.row]
        
        // 跳转到设备详情页
        let detailVC = DeviceDetailViewController()
        detailVC.hidesBottomBarWhenPushed = true
        detailVC.device = device
        PageManager.pushViewController(detailVC, animated: true)
    }
}


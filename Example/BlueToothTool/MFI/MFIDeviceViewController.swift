//
//  MFIDeviceViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/9/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool

class MFIDeviceViewController: BlueToothBaseTableViewController {
    
    // MARK: - Properties
    
    private let mfiManager = MFIManager.shared
    private var allDevices: [MFIDeviceModel] = []
    private var filteredDevices: [MFIDeviceModel] = []

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allDevices.removeAll()
        filteredDevices.removeAll()
        
        setupMFIManager()
        refreshDevices()
    }
    
    // MARK: - Setup
    
    override func setupNavigationBarStyle() {
        title = "MFI设备"
        
        // 设置搜索栏占位符
        searchBar.placeholder = "搜索设备名称或制造商"
    }
    
    override func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MFIDeviceCell.self, forCellReuseIdentifier: "MFIDeviceCell")
    }
    
    private func setupMFIManager() {
        // 创建一个定时器，每3s调用一次方法刷新设备列表
        startRefreshTimer()
        
        // 设置设备发现回调
        mfiManager.onDeviceDiscovered = { [weak self] device in
            DispatchQueue.main.async {
                self?.updateDeviceList()
            }
        }
        
        // 设置设备更新回调
        mfiManager.onDeviceUpdated = { [weak self] device in
            DispatchQueue.main.async {
                self?.updateDeviceList()
            }
        }
        
        // 设置设备断开回调
        mfiManager.onDeviceDisconnected = { [weak self] device in
            DispatchQueue.main.async {
                self?.updateDeviceList()
            }
        }
    }
    
    // MARK: - Abstract Methods Implementation
    
    override func numberOfDevices() -> Int {
        return filteredDevices.count
    }
    
    override func filterDevices() {
        if let searchText = searchBar.text, !searchText.isEmpty {
            let lowercasedSearchText = searchText.lowercased()
            filteredDevices = allDevices.filter { device in
                device.name.lowercased().contains(lowercasedSearchText) ||
                device.manufacturer.lowercased().contains(lowercasedSearchText) ||
                device.modelNumber.lowercased().contains(lowercasedSearchText) ||
                device.serialNumber.lowercased().contains(lowercasedSearchText)
            }
        } else {
            filteredDevices = allDevices
        }
        
        // 如果当前有排序类型，应用排序
        if let sortType = currentSortType {
            applySort(type: sortType)
        }
    }
    
    override func performRefresh() {
        refreshDevices()
    }
    
    override func emptyStateTitle() -> String {
        return "暂无MFI设备"
    }
    
    override func getAvailableSortTypes() -> [SortType] {
        return [.recentlyDiscovered]
    }
    
    override func applySort(type: SortType) {
        switch type {
        case .recentlyDiscovered:
            // 按发现时间降序排序（最新发现的靠前）
            filteredDevices.sort { $0.discoveredTime > $1.discoveredTime }
        case .nearestDistance:
            // MFI设备不支持距离排序，不处理
            break
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Device Management
    
    private func refreshDevices() {
        self.showActivity()
        mfiManager.refreshDevices()
        updateDeviceList()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {[weak self] in
            self?.hideActivity()
            // 结束下拉刷新动画
            self?.tableView.mj_header?.endRefreshing()
        })
    }
    
    
    // MARK: - Data Management
    
    override func updateDeviceList() {
        allDevices = mfiManager.devices
        filterDevices()
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension MFIDeviceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MFIDeviceCell", for: indexPath) as! MFIDeviceCell
        let device = filteredDevices[indexPath.row]
        cell.configure(with: device)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MFIDeviceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = filteredDevices[indexPath.row]
        
        // 跳转到设备详情页
        let detailVC = DeviceDetailViewController()
        detailVC.hidesBottomBarWhenPushed = true
        detailVC.mfiDevice = device
        PageManager.pushViewController(detailVC, animated: true)
    }
}


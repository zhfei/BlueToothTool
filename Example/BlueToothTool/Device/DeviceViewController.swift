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

class DeviceViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    private let bleManager = BLEManager.shared
    private var allDevices: [BLEDeviceModel] = []
    private var filteredDevices: [BLEDeviceModel] = []
    private var refreshTimer: Timer?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索设备名称或UUID"
        searchBar.backgroundColor = Color.lakeBlue
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = Color.white
        return searchBar
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = Color.white
        button.backgroundColor = Color.lakeBlue
        return button
    }()
    
    private let searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lakeBlue
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Color.backgroundGray
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allDevices.removeAll()
        filteredDevices.removeAll()
        
        setupUI()
        setupBLEManager()
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
        stopRefreshTimer()
    }
    
    deinit {
        stopRefreshTimer()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "BLE设备"
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        // 添加搜索容器视图
        view.addSubview(searchContainerView)
        searchContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        // 添加刷新按钮
        searchContainerView.addSubview(refreshButton)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        refreshButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        // 添加搜索栏
        searchContainerView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.right.equalTo(refreshButton.snp.left).offset(-8)
        }
        
        // 添加设备列表
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BLEDeviceCell.self, forCellReuseIdentifier: "BLEDeviceCell")
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
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
    
    // MARK: - Actions
    
    @objc private func refreshButtonTapped() {
        startScanning()
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
        })
    }
    
    private func stopScanning() {
        bleManager.stopScanning()
    }
    
    // MARK: - Timer Management
    
    private func startRefreshTimer() {
        stopRefreshTimer()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.updateDeviceList()
        }
        
        // 将定时器添加到 RunLoop 的 common modes，确保在滚动时也能触发
        if let timer = refreshTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - Data Management
    
    private func updateDeviceList() {
        allDevices = bleManager.devices
        filterDevices()
    }
    
    private func filterDevices() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            filteredDevices = allDevices
            tableView.reloadData()
            return
        }
        
        let lowercasedSearchText = searchText.lowercased()
        filteredDevices = allDevices.filter { device in
            device.name.lowercased().contains(lowercasedSearchText) ||
            device.identifier.lowercased().contains(lowercasedSearchText)
        }
        
        tableView.reloadData()
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

// MARK: - UISearchBarDelegate
extension DeviceViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterDevices()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterDevices()
    }
}

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

class MFIDeviceViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    private let mfiManager = MFIManager.shared
    private var allDevices: [MFIDeviceModel] = []
    private var filteredDevices: [MFIDeviceModel] = []
    private var refreshTimer: Timer?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索设备名称或制造商"
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
        setupMFIManager()
        refreshDevices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimer()
    }
    
    deinit {
        stopRefreshTimer()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "MFI设备"
        
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
        tableView.register(MFIDeviceCell.self, forCellReuseIdentifier: "MFIDeviceCell")
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
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
    
    // MARK: - Actions
    
    @objc private func refreshButtonTapped() {
        refreshDevices()
    }
    
    // MARK: - Device Management
    
    private func refreshDevices() {
        self.showActivity()
        mfiManager.refreshDevices()
        updateDeviceList()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {[weak self] in
            self?.hideActivity()
        })
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
        allDevices = mfiManager.devices
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
            device.manufacturer.lowercased().contains(lowercasedSearchText) ||
            device.modelNumber.lowercased().contains(lowercasedSearchText) ||
            device.serialNumber.lowercased().contains(lowercasedSearchText)
        }
        
        tableView.reloadData()
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

// MARK: - UISearchBarDelegate
extension MFIDeviceViewController: UISearchBarDelegate {
    
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

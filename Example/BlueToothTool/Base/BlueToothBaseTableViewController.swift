//
//  BlueToothBaseTableViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/17.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import DZNEmptyDataSet
import MJRefresh

/// 排序类型枚举
enum SortType {
    case nearestDistance    // 最近距离（仅BLE）
    case recentlyDiscovered // 最近搜索到的
    
    var displayName: String {
        switch self {
        case .nearestDistance:
            return "最近距离"
        case .recentlyDiscovered:
            return "最近搜索到的"
        }
    }
}

class BlueToothBaseTableViewController: BlueToothBaseViewController {
    
    // MARK: - Public Properties
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Color.backgroundGray
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = Color.lakeBlue
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = Color.white
        return searchBar
    }()
    
    let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = Color.white
        button.backgroundColor = Color.lakeBlue
        return button
    }()
    
    let sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("最近", for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = Color.lakeBlue
        return button
    }()
    
    let searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lakeBlue
        return view
    }()
    
    var refreshTimer: Timer?
    var currentSortType: SortType?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimer()
    }
    
    deinit {
        stopRefreshTimer()
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        // 设置导航栏样式（子类可重写）
        setupNavigationBarStyle()
        
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
        
        // 添加排序按钮
        searchContainerView.addSubview(sortButton)
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        sortButton.snp.makeConstraints { make in
            make.right.equalTo(refreshButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.width.equalTo(50)
        }
        
        // 添加搜索栏
        searchContainerView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.right.equalTo(sortButton.snp.left).offset(-8)
        }
        
        // 添加设备列表
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        // 配置 DZNEmptyDataSet
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        // 配置 MJRefresh 下拉刷新
        let header = MJRefreshNormalHeader { [weak self] in
            self?.performRefresh()
        }
        header.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        
        // 设置tableView（子类实现：注册cell、设置delegate和dataSource等）
        setupTableView()
    }
    
    // MARK: - Abstract Methods (子类必须实现)
    
    /// 返回过滤后的设备数量
    func numberOfDevices() -> Int {
        fatalError("子类必须实现 numberOfDevices()")
    }
    
    /// 执行设备过滤逻辑
    func filterDevices() {
        fatalError("子类必须实现 filterDevices()")
    }
    
    /// 执行刷新操作
    func performRefresh() {
        fatalError("子类必须实现 performRefresh()")
    }
    
    /// 返回空状态标题文字
    func emptyStateTitle() -> String {
        fatalError("子类必须实现 emptyStateTitle()")
    }
    
    /// 设置tableView（注册cell等）
    func setupTableView() {
        fatalError("子类必须实现 setupTableView()")
    }
    
    /// 设置导航栏样式（可选，提供默认空实现）
    func setupNavigationBarStyle() {
        // 默认空实现，子类可重写
    }
    
    /// 获取可用的排序类型
    func getAvailableSortTypes() -> [SortType] {
        fatalError("子类必须实现 getAvailableSortTypes()")
    }
    
    /// 应用排序
    func applySort(type: SortType) {
        fatalError("子类必须实现 applySort(type:)")
    }
    
    // MARK: - Actions
    
    @objc func refreshButtonTapped() {
        performRefresh()
    }
    
    @objc func sortButtonTapped() {
        let availableSortTypes = getAvailableSortTypes()
        
        guard !availableSortTypes.isEmpty else {
            return
        }
        
        let alert = UIAlertController(
            title: "排序方式",
            message: "请选择排序方式",
            preferredStyle: .actionSheet
        )
        
        for sortType in availableSortTypes {
            alert.addAction(UIAlertAction(title: sortType.displayName, style: .default) { [weak self] _ in
                self?.currentSortType = sortType
                self?.applySort(type: sortType)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad 支持
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sortButton
            popover.sourceRect = sortButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Timer Management
    
    func startRefreshTimer() {
        stopRefreshTimer()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.updateDeviceList()
        }
        
        // 将定时器添加到 RunLoop 的 common modes，确保在滚动时也能触发
        if let timer = refreshTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    /// 更新设备列表（触发过滤）
    func updateDeviceList() {
        filterDevices()
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate

extension BlueToothBaseTableViewController: UISearchBarDelegate {
    
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

// MARK: - DZNEmptyDataSetSource & DZNEmptyDataSetDelegate

extension BlueToothBaseTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = emptyStateTitle()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor.gray
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "下拉刷新或点击刷新按钮搜索设备"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.lightGray
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        // 当过滤后的设备列表为空时显示空状态
        return numberOfDevices() == 0
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        // 点击空状态时触发刷新
        performRefresh()
    }
}

// MARK: - UIScrollViewDelegate

extension BlueToothBaseTableViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 当用户开始拖动 tableView 时，隐藏键盘
        view.endEditing(true)
    }
}

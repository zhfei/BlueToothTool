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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "设备列表"
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        // 添加搜索按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: self,
            action: #selector(searchButtonTapped)
        )
        
        // 添加搜索栏
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索"
        searchBar.backgroundColor = Color.lakeBlue
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = Color.white
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        // 添加设备列表
        let tableView = UITableView()
        tableView.backgroundColor = Color.backgroundGray
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc private func searchButtonTapped() {
        // 搜索按钮点击事件
        print("搜索按钮被点击")
    }
}

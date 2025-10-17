//
//  DataPackageViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/9/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class DataPackageViewController: BlueToothBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "数据包"
        
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        // 添加数据包列表
        let tableView = UITableView()
        tableView.backgroundColor = Color.backgroundGray
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DataPackageCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

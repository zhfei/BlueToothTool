//
//  LogViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/9/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class LogViewController: BlueToothBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "日志"
        
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        // 添加日志列表
        let tableView = UITableView()
        tableView.backgroundColor = Color.backgroundGray
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LogCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

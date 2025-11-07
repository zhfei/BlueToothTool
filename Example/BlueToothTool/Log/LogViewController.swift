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
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.text = "账户未登录"
        label.textColor = UIColor.black
        label.backgroundColor = .gray
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        self.view.addSubview(label)
        label.snp.makeConstraints { (maker) in
            maker.width.equalToSuperview().inset(20)
            maker.height.equalToSuperview().inset(150)
            maker.center.equalToSuperview()
//            maker.top.equalTo(imageView.snp.bottom).offset(18)
        }
        return label
    }()

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
        
//        // 添加日志列表
//        let tableView = UITableView()
//        tableView.backgroundColor = Color.backgroundGray
//        tableView.separatorStyle = .none
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LogCell")
//        
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        
        let ctx = "# Cold Calling Performance Analysis\\n## Overall Trend in Cold Call Performance  \\n\\nOver time, \\n\\n\\nthe user\'s cold calling performance has demonstrated **incremental but inconsistent progress**. Initial sessions showed an extremely passive approach, where the user spoke little and allowed conversations to be led entirely by the prospect."
        contentLabel.setMarkdownTextForLabel(ctx)
        
    }
}

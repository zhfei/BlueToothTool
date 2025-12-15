//
//  CMDListViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/12/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool

class CMDListViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    private var commands: [CommandItem] = []
    
    private let commandsFileName = "CommandList.plist"
    
    private var commandsFilePath: URL {
        return FileUtils.shared.getDocumentsDirectory().appendingPathComponent(commandsFileName)
    }
    
    // MARK: - UI Components
    
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
        setupNavigationBar()
        loadCommands()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCommands()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "指令列表"
        
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
        tableView.register(CommandItemCell.self, forCellReuseIdentifier: "CommandItemCell")
    }
    
    private func setupNavigationBar() {
        // 编辑按钮
        let editButton = UIBarButtonItem(
            title: "编辑",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        navigationItem.rightBarButtonItem = editButton
    }
    
    // MARK: - Data Management
    
    private func loadCommands() {
        guard FileUtils.shared.fileExists(at: commandsFilePath) else {
            commands = []
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            return
        }
        
        guard let data = FileUtils.shared.readFile(at: commandsFilePath) else {
            commands = []
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            return
        }
        
        do {
            let decoder = PropertyListDecoder()
            // 按创建时间倒序排列（最新的在前）
            let loadedCommands = try decoder.decode([CommandItem].self, from: data)
            commands = loadedCommands.sorted(by: { $0.createTime > $1.createTime })
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        } catch {
            print("❌ 加载指令列表失败: \(error.localizedDescription)")
            commands = []
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    private func saveCommands() -> Bool {
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let data = try encoder.encode(commands)
            return FileUtils.shared.createFile(at: commandsFilePath, contents: data)
        } catch {
            print("❌ 保存指令列表失败: \(error.localizedDescription)")
            return false
        }
    }
    
    private func deleteCommand(at index: Int) {
        guard index < commands.count else { return }
        commands.remove(at: index)
        
        if saveCommands() {
            print("✅ 指令删除成功")
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        } else {
            print("❌ 指令删除失败")
            // 如果保存失败，恢复数据
            loadCommands()
        }
    }
    
    // MARK: - Actions
    
    @objc private func editButtonTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        let editButton = navigationItem.rightBarButtonItem
        editButton?.title = tableView.isEditing ? "完成" : "编辑"
        editButton?.style = tableView.isEditing ? .done : .plain
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CMDListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommandItemCell", for: indexPath) as! CommandItemCell
        let command = commands[indexPath.row]
        cell.configure(with: command)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Editing Support
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCommand(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}

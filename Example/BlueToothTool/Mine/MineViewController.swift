//
//  SettingViewController.swift
//  BlueToothTool_Example
//
//  Created by 周飞 on 2025/9/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import BlueToothTool

class MineViewController: BlueToothBaseViewController {
    
    // MARK: - Properties
    
    /// 用户信息
    private var userName: String? {
        didSet {
            updateAccountInfo()
        }
    }
    
    /// 是否已登录
    private var isLoggedIn: Bool = false {
        didSet {
            updateAccountInfo()
            tableView.reloadData()
        }
    }
    
    /// 当前主题色索引
    private var currentThemeIndex: Int = 0 {
        didSet {
            UserDefaults.standard.set(currentThemeIndex, forKey: "CurrentThemeIndex")
        }
    }
    
    /// 当前语言代码
    private var currentLanguage: String = "zh-Hans" {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "CurrentLanguage")
            // 这里可以触发语言切换
        }
    }
    
    /// 可用主题色列表
    private let themes: [(name: String, color: UIColor)] = [
        ("默认蓝色", Color.lakeBlue),
        ("紫色", Color.purple),
        ("绿色", Color.green),
        ("橙色", Color.orange),
        ("红色", Color.red)
    ]
    
    /// 可用语言列表
    private let languages: [(code: String, name: String)] = [
        ("zh-Hans", "简体中文"),
        ("en", "English"),
        ("zh-Hant", "繁體中文"),
        ("ja", "日本語"),
        ("ko", "한국어")
    ]
    
    /// 设置项列表
    private let settingItems: [SettingItem] = [
        SettingItem(title: "主题色切换", type: .theme),
        SettingItem(title: "语言选择", type: .language),
        SettingItem(title: "添加调试指令", type: .debugCommand)
    ]
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Color.backgroundGray
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.backgroundGray
        return view
    }()
    
    private let accountHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color.lakeBlue
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        // 使用系统图标作为默认头像
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = Color.white
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = Color.primaryText
        label.text = "未登录"
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录账号", for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.backgroundColor = Color.lakeBlue
        button.layer.cornerRadius = 20
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Color.backgroundGray
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserInfo()
        loadSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserInfo()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "我的"
        
        // 设置导航栏样式
        navigationController?.navigationBar.backgroundColor = Color.lakeBlue
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: Color.white
        ]
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 账号信息区域
        contentView.addSubview(accountHeaderView)
        accountHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview()
        }
        
        accountHeaderView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(80)
        }
        
        accountHeaderView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
        }
        
        accountHeaderView.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(userNameLabel.snp.bottom).offset(20)
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // 设置列表
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(accountHeaderView.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(CGFloat(settingItems.count * 60))
            make.bottom.equalToSuperview().offset(-16)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
    }
    
    // MARK: - Data Management
    
    private func loadUserInfo() {
        // 从 UserDefaults 加载用户信息
        userName = UserDefaults.standard.string(forKey: "UserName")
        isLoggedIn = userName != nil && !userName!.isEmpty
    }
    
    private func loadSettings() {
        // 加载主题设置
        currentThemeIndex = UserDefaults.standard.integer(forKey: "CurrentThemeIndex")
        if currentThemeIndex >= themes.count {
            currentThemeIndex = 0
        }
        
        // 加载语言设置
        currentLanguage = UserDefaults.standard.string(forKey: "CurrentLanguage") ?? "zh-Hans"
    }
    
    private func updateAccountInfo() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.isLoggedIn, let userName = self.userName {
                self.userNameLabel.text = userName
                self.loginButton.setTitle("退出登录", for: .normal)
            } else {
                self.userNameLabel.text = "未登录"
                self.loginButton.setTitle("登录账号", for: .normal)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        if isLoggedIn {
            // 退出登录
            let alert = UIAlertController(
                title: "确认退出",
                message: "确定要退出登录吗？",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
                self?.logout()
            })
            present(alert, animated: true)
        } else {
            // 登录
            showLoginAlert()
        }
    }
    
    private func showLoginAlert() {
        let alert = UIAlertController(
            title: "登录账号",
            message: "请输入用户名",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "用户名"
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "登录", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let userName = textField.text,
                  !userName.isEmpty else {
                return
            }
            
            self.userName = userName
            self.isLoggedIn = true
            UserDefaults.standard.set(userName, forKey: "UserName")
        })
        
        present(alert, animated: true)
    }
    
    private func logout() {
        userName = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "UserName")
    }
    
    private func showThemeSelection() {
        let alert = UIAlertController(
            title: "选择主题色",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for (index, theme) in themes.enumerated() {
            let isSelected = index == currentThemeIndex
            let title = isSelected ? "\(theme.name) ✓" : theme.name
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.currentThemeIndex = index
                self?.showThemeChangedAlert(themeName: theme.name)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad 支持
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showThemeChangedAlert(themeName: String) {
        let alert = UIAlertController(
            title: "主题已切换",
            message: "已切换到 \(themeName)，重启应用后生效",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showLanguageSelection() {
        let alert = UIAlertController(
            title: "选择语言",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for language in languages {
            let isSelected = language.code == currentLanguage
            let title = isSelected ? "\(language.name) ✓" : language.name
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.currentLanguage = language.code
                self?.showLanguageChangedAlert(languageName: language.name)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad 支持
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showLanguageChangedAlert(languageName: String) {
        let alert = UIAlertController(
            title: "语言已切换",
            message: "已切换到 \(languageName)，重启应用后生效",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showDebugCommandInput() {
        let alert = UIAlertController(
            title: "添加调试指令",
            message: "请输入调试指令",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "指令内容"
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let command = textField.text,
                  !command.isEmpty else {
                return
            }
            
            // 保存调试指令到 UserDefaults
            var commands = UserDefaults.standard.stringArray(forKey: "DebugCommands") ?? []
            commands.append(command)
            UserDefaults.standard.set(commands, forKey: "DebugCommands")
            
            // 显示成功提示
            let successAlert = UIAlertController(
                title: "添加成功",
                message: "调试指令已添加：\(command)",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MineViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        let item = settingItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settingItems[indexPath.row]
        switch item.type {
        case .theme:
            showThemeSelection()
        case .language:
            showLanguageSelection()
        case .debugCommand:
            showDebugCommandInput()
        }
    }
}

// MARK: - Supporting Types

struct SettingItem {
    let title: String
    let type: SettingType
    
    enum SettingType {
        case theme
        case language
        case debugCommand
    }
}

class SettingCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Color.primaryText
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = Color.grayText
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = Color.backgroundGray
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        containerView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    func configure(with item: SettingItem) {
        titleLabel.text = item.title
    }
}

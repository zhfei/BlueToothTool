//
//  ProgressNavigationBar.swift
//  RepReady
//
//  Created by Jim Learning on 2025/6/14.
//

import UIKit
import SnapKit

class TaskProgressNavigationBar: UIView {

    // MARK: - Callbacks
    var onBack: (() -> Void)?
    var onClose: (() -> Void)?

    // MARK: - UI Components
    let progressBar = TaskProgressBar()
    private let backButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)
    
    private let actionsContainerView = UIView()
    private let containerStackView = UIStackView()
    
    // 添加标题标签
    private(set) var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0 // 支持多行
        label.adjustsFontSizeToFitWidth = true // 字体自适应
        label.minimumScaleFactor = 0.8 // 最小缩放比例
        return label
    }()

    // MARK: - Initializer
    init(
        maxProgress: CGFloat = 1.0,
        currentProgress: CGFloat = 0.0,
        themeColor: UIColor = Color.green,
        edgeInsets: UIEdgeInsets = .zero,
        spacing: CGFloat = 0
    ) {
        super.init(frame: .zero)

        // --- Configure Components ---
        progressBar.update(progress: currentProgress, maxProgress: maxProgress, animated: false)
        progressBar.setProgressColor(themeColor)

        backButton.setImage(UIImage(named: "icon_back_60x60"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        closeButton.setImage(UIImage(named: "icon_close_60x60"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        titleLabel.text = nil

        // --- Setup UI Hierarchy ---
        actionsContainerView.addSubview(backButton)
        actionsContainerView.addSubview(closeButton)
        actionsContainerView.addSubview(titleLabel)

        containerStackView.axis = .vertical
        containerStackView.spacing = spacing
        containerStackView.addArrangedSubview(progressBar)
        containerStackView.addArrangedSubview(actionsContainerView)

        addSubview(containerStackView)

        // --- Layout ---
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(edgeInsets)
        }

        progressBar.snp.makeConstraints { make in
            make.height.equalTo(10)
            
        }

        backButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(60)
        }

        closeButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.left.equalTo(backButton.snp.right).offset(8)
            make.right.equalTo(closeButton.snp.left).offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions
    @objc private func didTapBack() {
        onBack?()
    }

    @objc private func didTapClose() {
        onClose?()
    }
    
    // MARK: - Public Methods
    func update(progress: CGFloat, maxProgress: CGFloat, animated: Bool = true) {
        progressBar.update(progress: progress, maxProgress: maxProgress, animated: animated)
    }
    
    // 设置导航条标题
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    // 配置标题样式
    func configureTitleLabel(font: UIFont? = nil, textColor: UIColor? = nil, alignment: NSTextAlignment? = nil) {
        if let font = font {
            titleLabel.font = font
        }
        
        if let textColor = textColor {
            titleLabel.textColor = textColor
        }
        
        if let alignment = alignment {
            titleLabel.textAlignment = alignment
        }
    }
}

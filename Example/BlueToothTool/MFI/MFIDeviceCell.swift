//
//  MFIDeviceCell.swift
//  BlueToothTool_Example
//
//  Created by zhoufei on 2025/01/XX.
//

import UIKit
import SnapKit
import BlueToothTool

class MFIDeviceCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Color.primaryText
        label.numberOfLines = 1
        return label
    }()
    
    private let manufacturerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = Color.grayText
        label.numberOfLines = 1
        return label
    }()
    
    private let modelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Color.lakeBlue
        return label
    }()
    
    private let serialLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Color.green
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
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
        
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }
        
        containerView.addSubview(manufacturerLabel)
        manufacturerLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        containerView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(manufacturerLabel.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        infoStackView.addArrangedSubview(modelLabel)
        infoStackView.addArrangedSubview(serialLabel)
    }
    
    // MARK: - Configure
    
    func configure(with device: MFIDeviceModel) {
        nameLabel.text = device.name
        manufacturerLabel.text = "制造商: \(device.manufacturer)"
        modelLabel.text = "型号: \(device.modelNumber.isEmpty ? "未知" : device.modelNumber)"
        serialLabel.text = "序列号: \(device.serialNumber.isEmpty ? "未知" : device.serialNumber)"
        
        if device.name.isEmpty {
            nameLabel.text = device.modelNumber
        }
    }
}


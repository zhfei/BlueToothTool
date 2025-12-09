//
//  BLEDeviceCell.swift
//  BlueToothTool_Example
//
//  Created by zhoufei on 2025/01/XX.
//

import UIKit
import SnapKit
import BlueToothTool

class BLEDeviceCell: UITableViewCell {
    
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
        label.textColor = Color.red
        label.numberOfLines = 1
        return label
    }()
    
    private let uuidLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = Color.grayText
        label.numberOfLines = 1
        return label
    }()
    
    private let rssiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Color.lakeBlue
        return label
    }()
    
    private let distanceLabel: UILabel = {
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
        
        containerView.addSubview(uuidLabel)
        uuidLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        containerView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(uuidLabel.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        infoStackView.addArrangedSubview(rssiLabel)
        infoStackView.addArrangedSubview(distanceLabel)
    }
    
    // MARK: - Configure
    
    func configure(with device: BLEDeviceModel) {
        nameLabel.text = device.name
        uuidLabel.text = "UUID: \(device.identifier)"
        rssiLabel.text = "RSSI: \(device.rssi) dBm"
        
        let distanceText: String
        if device.distance < 0 {
            distanceText = "距离: 未知"
        } else if device.distance < 1 {
            distanceText = String(format: "距离: %.2f m", device.distance)
        } else {
            distanceText = String(format: "距离: %.1f m", device.distance)
        }
        distanceLabel.text = distanceText
    }
}


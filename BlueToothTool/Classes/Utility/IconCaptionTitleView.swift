//
//  IconTitleView.swift
//  RepReady
//
//  Created by Jim Learning on 2025/6/14.
//

import UIKit

class IconCaptionTitleView: UIView {

    enum Layout {
        case captionFirst
        case titleFirst
    }
    
    var titleNumberOfLines: Int {
        get { return titleLabel.numberOfLines }
        set { titleLabel.numberOfLines = newValue }
    }

    // MARK: - UI Components
    private let iconCaptionView: IconCaptionView
    private let titleLabel = UILabel()

    private let containerStackView = UIStackView()

    // MARK: - Initializer
    init(
        icon: UIImage?,
        caption: String,
        title: String,
        themeColor: UIColor,
        edgeInsets: UIEdgeInsets = .zero,
        layout: Layout = .captionFirst,
        spacing: CGFloat = 8, // Spacing between IconCaptionView and TitleLabel
        iconCaptionSpacing: CGFloat = 5, // Spacing within IconCaptionView
        titleFont: UIFont = .boldSystemFont(ofSize: 20)
    ) {
        self.iconCaptionView = IconCaptionView(
            icon: icon, 
            caption: caption, 
            themeColor: themeColor, 
            spacing: iconCaptionSpacing, 
            iconSize: CGSize(width: 23, height: 23), 
            captionFont: .systemFont(ofSize: 18, weight: .semibold)
        )
        super.init(frame: .zero)
        
        // --- Configure Components ---
        titleLabel.text = title
        titleLabel.font = titleFont // Example font
        titleLabel.textColor = Color.white // Or your desired title color
        titleLabel.numberOfLines = 0
        
        // --- Configure StackViews ---
        containerStackView.axis = .vertical
        containerStackView.spacing = spacing // Spacing between icon/caption group and title
        containerStackView.alignment = .leading

        // --- Add Subviews ---
        switch layout {
        case .captionFirst:
            containerStackView.addArrangedSubview(iconCaptionView)
            containerStackView.addArrangedSubview(titleLabel)
        case .titleFirst:
            containerStackView.addArrangedSubview(titleLabel)
            containerStackView.addArrangedSubview(iconCaptionView)
        }
        
        addSubview(containerStackView)

        // --- Layout ---
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(edgeInsets)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func update(title: String? = nil, icon: UIImage? = nil, caption: String? = nil, themeColor: UIColor? = nil) {
        if let title = title {
            self.titleLabel.text = title
        }
        // Pass through updates to the iconCaptionView
        // Note: themeColor here will update the iconCaptionView's theme. If titleLabel needs a separate theme, manage it directly.
        self.iconCaptionView.update(icon: icon, caption: caption, themeColor: themeColor)
    }
}

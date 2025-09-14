import UIKit
import SnapKit

class IconCaptionView: UIView {

    // MARK: - UI Components
    private let iconImageView = UIImageView()
    private let captionLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Initializer
    init(
        icon: UIImage?,
        caption: String,
        themeColor: UIColor,
        spacing: CGFloat = 5,
        iconSize: CGSize = CGSize(width: 23, height: 23),
        captionFont: UIFont = .systemFont(ofSize: 18, weight: .medium)
    ) {
        super.init(frame: .zero)

        // --- Configure Components ---
        iconImageView.image = icon?.withTintColor(themeColor)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = themeColor

        captionLabel.text = caption
        captionLabel.textColor = themeColor
        captionLabel.font = captionFont
        captionLabel.numberOfLines = 0

        // --- Configure StackView ---
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .top

        // --- Add Subviews ---
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(captionLabel)
        addSubview(stackView)

        // --- Layout ---
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(iconSize.width)
            make.height.equalTo(iconSize.height)
        }
        
        captionLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(23).priority(.medium)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    /// Updates the view's components. Pass nil for any parameter you don't want to change.
    func update(icon: UIImage? = nil, caption: String? = nil, themeColor: UIColor? = nil, iconSize: CGSize? = nil, captionFont: UIFont? = nil) {
        if let icon = icon {
            self.iconImageView.image = icon.withTintColor(themeColor ?? self.iconImageView.tintColor)
        }
        if let caption = caption {
            self.captionLabel.text = caption
        }
        if let themeColor = themeColor {
            self.iconImageView.tintColor = themeColor
            self.captionLabel.textColor = themeColor
        }
        if let iconSize = iconSize {
            iconImageView.snp.updateConstraints { make in
                make.width.equalTo(iconSize.width)
                make.height.equalTo(iconSize.height)
            }
        }
        if let captionFont = captionFont {
            self.captionLabel.font = captionFont
        }
    }

    // Older update methods (consider deprecating or removing if new 'update' method is sufficient)
    func updatecaptionText(_ text: String) {
        captionLabel.text = text
    }
    
    func updateIcon(_ icon: UIImage?) {
        iconImageView.image = icon
    }
    
    func updateThemeColor(_ color: UIColor) {
        iconImageView.tintColor = color
        captionLabel.textColor = color
    }
}

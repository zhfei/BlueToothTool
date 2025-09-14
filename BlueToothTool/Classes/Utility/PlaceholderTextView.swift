//
//  PlaceholderTextView.swift
//  RepReady
//
//  Created by Jim Learning on 2024/2/28.
//

import UIKit

@IBDesignable
class PlaceholderTextView: UITextView {
    private let placeholderView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        tv.textColor = UIColor.lightGray
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    @IBInspectable
    var placeholder: String? {
        didSet {
            placeholderView.text = placeholder
            setNeedsLayout()
        }
    }

    @IBInspectable
    var placeholderColor: UIColor? {
        didSet {
            placeholderView.textColor = placeholderColor
        }
    }

    var lineSpacing: CGFloat = 8

    override var font: UIFont? {
        didSet {
            placeholderView.font = font
        }
    }

    override var textContainerInset: UIEdgeInsets {
        didSet {
            placeholderView.textContainerInset = textContainerInset
        }
    }

    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderView.textAlignment = textAlignment
        }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            updatePlaceholderVisibility()
        }
    }

    override var text: String! {
        didSet {
            updatePlaceholderVisibility()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderView.frame = self.bounds
        placeholderView.font = self.font
        placeholderView.textContainerInset = self.textContainerInset
        placeholderView.textAlignment = self.textAlignment
        placeholderView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding
        bringSubviewToFront(placeholderView)
    }

    private func updatePlaceholderVisibility() {
        placeholderView.isHidden = !self.text.isEmpty
    }

    @objc private func textDidChange() {
        updatePlaceholderVisibility()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }

    private func setup() {
        addSubview(placeholderView)
        placeholderView.isHidden = !self.text.isEmpty
        placeholderView.font = self.font
        placeholderView.textContainerInset = self.textContainerInset
        placeholderView.textAlignment = self.textAlignment
        placeholderView.backgroundColor = .clear
        placeholderView.textColor = placeholderColor ?? UIColor.lightGray
        placeholderView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

extension PlaceholderTextView: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return lineSpacing
    }
}

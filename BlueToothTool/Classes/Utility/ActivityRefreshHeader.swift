//
//  ActivityRefreshHeader.swift
//  RepReady
//
//  Created by Jim Learning on 2025/6/19.
//

import UIKit
import PullToRefreshKit

class ActivityRefreshHeader: UIView {
    
    public var preferredHeight: CGFloat = 60
    
    open fileprivate(set) var animating: Bool = false
    
    private var containerView = UIView()
    
    private lazy var activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        indicator.color = Color.white
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        containerView.addSubview(activityIndicator)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = bounds
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY + 30)
    }
    
    open override func didMoveToWindow() {
        if window != nil && animating {
            startAnimating()
        }
    }
}

extension ActivityRefreshHeader: RefreshableHeader {
    
    func heightForHeader()->CGFloat {
        return preferredHeight
    }
    
    func heightForFireRefreshing()->CGFloat {
        return preferredHeight * 1.5
    }
    
    func heightForRefreshingState()->CGFloat {
        return 0
    }
    
    func didBeginRefreshingState() {
        startAnimating()
    }
    
    func didBeginHideAnimation(_ result:RefreshResult) {
        stopAnimating()
    }
    
    func didCompleteHideAnimation(_ result:RefreshResult) {
        stopAnimating()
    }
    
    func stateDidChanged(_ oldState:RefreshHeaderState, newState:RefreshHeaderState) {
        if newState == .pulling {
            startAnimating()
        } else if newState == .idle {
            stopAnimating()
        }
    }
}

extension ActivityRefreshHeader {
    
    func startAnimating() {
        animating = true
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    func stopAnimating() {
        animating = false
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

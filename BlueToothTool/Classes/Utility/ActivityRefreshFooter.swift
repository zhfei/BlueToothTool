//
//  TwoColumnListView.swift
//  RepReady
//
//  Created by Jim Learning on 2023/7/30.
//

import UIKit
import PullToRefreshKit

class ActivityRefreshFooter: UIView {
    
    public var preferredHeight: CGFloat = 60
    
    open fileprivate(set) var animating: Bool = false
    
    private var containerView = UIView()
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        
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
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    open override func didMoveToWindow() {
        if window != nil && animating {
            startAnimating()
        }
    }
}

extension ActivityRefreshFooter: RefreshableFooter {
    
    func heightForFooter() -> CGFloat {
        return preferredHeight
    }
    
    func didUpdateToNoMoreData() {
        stopAnimating()
    }
    
    func didResetToDefault() {
        stopAnimating()
    }
    
    func didEndRefreshing() {
        stopAnimating()
    }
    
    func didBeginRefreshing() {
        startAnimating()
    }
    
    func shouldBeginRefreshingWhenScroll() -> Bool {
        return true
    }
}

extension ActivityRefreshFooter {
    
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

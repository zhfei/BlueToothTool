//
//  UITableView+Extensions.swift
//  RepReady
//
//  Created by 周飞 on 2025/8/23.
//

import UIKit

extension UITableView {
    
    /// 滚动到 TableView 底部
    /// - Parameter animated: 是否使用动画
    func f_scrollToBottom(animated: Bool = true) {
        guard let dataSource = dataSource else { return }
        
        let numberOfSections = dataSource.numberOfSections?(in: self) ?? 0
        guard numberOfSections > 0 else { return }
        
        let lastSection = numberOfSections - 1
        let numberOfRows = dataSource.tableView(self, numberOfRowsInSection: lastSection)
        guard numberOfRows > 0 else { return }
        
        let lastIndexPath = IndexPath(row: numberOfRows - 1, section: lastSection)
        
        // 确保 IndexPath 有效
        if lastIndexPath.section < numberOfSections && 
           lastIndexPath.row < numberOfRows {
            scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
        } else {
            // 如果 IndexPath 无效，使用 contentOffset 滚动到底部
            let bottomOffset = CGPoint(
                x: 0,
                y: contentSize.height - bounds.height + contentInset.bottom
            )
            setContentOffset(bottomOffset, animated: animated)
        }
    }
}

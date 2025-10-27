//
//  NSCollectionLayout+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension NSCollectionLayoutGroup {
    class func vertical(
        layoutSize: NSCollectionLayoutSize, batchSubitem subitem: NSCollectionLayoutItem, count: Int
    ) -> Self {
        if #available(iOS 16.0, *) {
            return self.vertical(layoutSize: layoutSize, repeatingSubitem: subitem, count: count)
        } else {
            return self.vertical(layoutSize: layoutSize, subitem: subitem, count: count)
        }
    }

    class func horizontal(
        layoutSize: NSCollectionLayoutSize, batchSubitem subitem: NSCollectionLayoutItem, count: Int
    ) -> Self {
        if #available(iOS 16.0, *) {
            return self.horizontal(layoutSize: layoutSize, repeatingSubitem: subitem, count: count)
        } else {
            return self.horizontal(layoutSize: layoutSize, subitem: subitem, count: count)
        }
    }
}


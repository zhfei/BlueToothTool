//
//  UITableView+FDTemplateLayoutCellDebug.swift
//  TableViewDynamicHeight
//
//  Created by 伯驹 黄 on 2017/2/22.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

extension UITableView {

    private struct Keys {
        static var debugLogEnabled = "debugLogEnabled"
    }

    public var fd_debugLogEnabled: Bool {
        set {
            let key = UnsafePointer(&Keys.debugLogEnabled)
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            let key = UnsafePointer(&Keys.debugLogEnabled)
            return objc_getAssociatedObject(self, key) as? Bool ?? false
        }
    }

    func fd_debugLog(_ message: String) {
        if fd_debugLogEnabled {
            print("** FDTemplateLayoutCell ** \(message)")
        }
    }
}

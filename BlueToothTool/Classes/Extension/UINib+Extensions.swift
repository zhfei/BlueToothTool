//
//  UINib+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension UINib {

    static func loadNibIfExists(for cellClass: AnyClass) -> UINib? {
        let nibName = String(describing: cellClass)
        guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
            return nil
        }
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib
    }
}

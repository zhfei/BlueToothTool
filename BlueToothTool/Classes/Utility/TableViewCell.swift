//
//  TableViewCell.swift
//  JingChat
//
//  Created by Jim Learning on 2023/6/1.
//

import UIKit

class TableViewCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textLabelFrame = textLabel?.frame
        let newOriginX = CGFloat(15)
        textLabel?.frame = CGRect(x: newOriginX, y: textLabelFrame?.minY ?? 0, width: textLabelFrame?.width ?? 0, height: textLabelFrame?.height ?? 0)
    }
}

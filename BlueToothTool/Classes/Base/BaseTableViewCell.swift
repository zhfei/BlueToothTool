//
//  BaseTableViewCell.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/9/15.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


public protocol BaseTableViewCellProtocol: NSObjectProtocol {

    func cellHeight(item: Any) -> CGFloat 

}


//
//  RunTimeData.swift
//  RepReady
//
//  Created by 周飞 on 2025/8/23.
//

import UIKit

class RunTimeData: NSObject {
    
    static let shared = RunTimeData()
    
    var showMainTabLaunch: Bool = false

    //从新手体验课进入Home
    var isFromFirstCourseEnter: Bool = false

}

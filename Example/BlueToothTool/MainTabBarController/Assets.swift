//
//  Assets.swift
//  JingChat
//
//  Created by Jim Learning on 2023/5/29.
//

import UIKit
import SwifterSwift

typealias Color = Assets.Color
typealias ImageName = Assets.ImageName

struct Assets {
    struct Color {
        static let purple = #colorLiteral(red: 0.4705882353, green: 0.3098039216, blue: 0.8196078431, alpha: 1) // UIColor(hex: 0x7045FF)!
        static let green = #colorLiteral(red: 0.3098039216, green: 0.8196078431, blue: 0.7725490196, alpha: 1) // UIColor(hex: 0x30E3CA)!
        static let greenLight = #colorLiteral(red: 0.1882352941, green: 0.8901960784, blue: 0.7921568627, alpha: 0.5034147351) // UIColor(hex: 0x30E3CA, transparency: 0.5)!
        static let greenHighlight = #colorLiteral(red: 0, green: 0.7058823529, blue: 0.6078431373, alpha: 1) // UIColor(hex: 0x00B49B)!
        static let teal = #colorLiteral(red: 0.2, green: 0.8, blue: 0.8, alpha: 1) // UIColor(hex: 0x33CCCC)!
        static let red = #colorLiteral(red: 0.8196078431, green: 0.3098039216, blue: 0.3098039216, alpha: 1) // UIColor(hex: 0xD14F4F)!
        static let orange = #colorLiteral(red: 1, green: 0.7058823529, blue: 0, alpha: 1) // UIColor(hex: 0xFFB400)!
        static let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // UIColor.white
        static let black = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // UIColor.black
        static let clear = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) // UIColor.clear
        
        static let lakeBlue = #colorLiteral(red: 0.1411764706, green: 0.8117647059, blue: 1, alpha: 1) // UIColor(hex: 0x24CFFF)!
        static let bluePurple = #colorLiteral(red: 0.4705882353, green: 0.3098039216, blue: 0.8196078431, alpha: 1) // UIColor(hex: 0x784FD1)!
        static let amberOrange = #colorLiteral(red: 0.8784313725, green: 0.5411764706, blue: 0.1294117647, alpha: 1) // UIColor(hex: 0xE08A21)
        static let lemonYellow = #colorLiteral(red: 1, green: 0.8352941176, blue: 0, alpha: 1) // UIColor(hex: 0xFFD500)
        
        static let primaryText = #colorLiteral(red: 0.007843137255, green: 0.01568627451, blue: 0.2196078431, alpha: 1) // UIColor(hex: 0x020438)!
        static let grayText = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) // UIColor(hex: 0x999999)!
        static let grayLightText = #colorLiteral(red: 0.7921568627, green: 0.7921568627, blue: 0.7921568627, alpha: 1) // UIColor(hex: 0xCACACA)!
        static let whiteText = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7959695778) // UIColor(white: 1.0, alpha: 0.8)
        static let seperatorLine = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) // UIColor(hex: 0xF5F5F5)!
        
        static let background = #colorLiteral(red: 0.0862745098, green: 0.07843137255, blue: 0.1411764706, alpha: 1) // UIColor(hex: 0xFCFCFC)!
        static let background2 = #colorLiteral(red: 0.0862745098, green: 0.07843137255, blue: 0.1411764706, alpha: 1) // UIColor(hex: 0x161424)!
        static let background3 = #colorLiteral(red: 0.1764705882, green: 0.1725490196, blue: 0.2431372549, alpha: 1) // UIColor(hex: 0x2D2C3E)!
        static let backgroundChat = #colorLiteral(red: 0.1764705882, green: 0.2156862745, blue: 0.2823529412, alpha: 1) // UIColor(hex: 0x2D3748)!
        static let backgroundWelcome = #colorLiteral(red: 0.0862745098, green: 0.07843137255, blue: 0.1411764706, alpha: 1) // UIColor(hex: 0x2D3748)!
        static let backgroundGray = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) // UIColor(hex: 0xF5F5F5)!
        static let backgroundGray2 = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1) // UIColor(hex: 0xD9D9D9)!
        
        // 每日限制页面专用颜色
        static let limitBackground = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1803921569, alpha: 1) // UIColor(hex: 0x1A1A2E)!
        static let limitYellow = #colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1) // UIColor(hex: 0xFFD700)!
        
        static let backgroundSelectQuestion = #colorLiteral(red: 0.1764705882, green: 0.2156862745, blue: 0.2823529412, alpha: 1) // UIColor(hex: 0xD9D9D9)!
        
        static let darkGray = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // Dark gray for progress backgrounds
        static let darkGray2 = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1) // UIColor(hex: 0x1C1C1E)!
        static let gray = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) // Gray for inactive badges
        static let lightGray = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 0.1) // Light gray for inactive badges
        static let groupedBackground = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1) // Grouped background for separators
    }
    struct ImageName {
        static let empty = "empty-placeholder"
        static let listPlaceholder = "list-placeholder"
        static let toastCompleted = "toast-completed"
        static let toastError = "toast-error"
        static let toastTip = "toast-tip"
    }
    enum ToastImageType {
        case none
        case completed
        case error
        case tip
        case custom(image: UIImage)
    }
}

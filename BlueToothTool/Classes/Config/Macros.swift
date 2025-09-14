//
//  Macros.swift
//  JingChat
//
//  Created by Jim Learning on 2023/6/8.
//

import UIKit

let documentsPath =
NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as? NSString

extension IndexPath {
    static let zero = IndexPath(item: 0, section: 0)
}

struct Constants {
    struct TableName {
        static let currentUserInfo = "CurrentUserInfo"
    }
    struct Path {
        static let database =
        documentsPath?.appendingPathComponent("RepReady.db") ?? NSHomeDirectory()
        + "Documents/RepReady.db"
    }
    struct SectionElementKind {
        static let background1 = "background1"
        static let gradientBackground1 = "gradientBackground1"
        static let gradientBackground2 = "gradientBackground2"
        static let gradientBackground3 = "gradientBackground3"
        static let gradientBackground4 = "gradientBackground4"
    }
    struct Identifier {
        static let wechatAppId = ""
        static let wechatAppSecret = ""
        static let aliPayScheme = ""
    }
    struct URL {
        static let universalLink = ""
        static let userProtocol = ""
        static let privacyProtocol = ""
    }
    struct EdgeInset {
        static let leftRight = 20.0
    }
    struct Link {
        static let privacyPolicy = "https://repready-aa961.web.app/privacy-policy.html"
        static let termsOfService = "https://repready-aa961.web.app/terms-of-service.html"
        static let feedback = "https://cruu.me/invite/a5686af656cb96a14b81bacaf215eb136976e6007ebef7ab88c014f7a679bb14"
    }
    struct StyledHTML {
        static let pre = """
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            background-color: transparent;
            color: #fff;
            font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-size: 16px;
            font-weight: bold;
            line-height: 1.6;
            padding-top: 0px;
            padding-right: 22px;
            padding-bottom: 0px;
            padding-left: 22px;
            text-align: left;
          }
          h3 {
            color: #fff; /* title color */
          }
          ul {
            padding-left: 20px;
          }
          li {
            margin-bottom: 8px;
          }
          a {
            color: #00BFFF; /* link color */
          }
          .br-gap {
            display: block;
            height: 1px;
          }
        </style>
      </head>
      <body>
      """
        static let post = """
      </body>
      </html>
      """
    }
    
    
    
    
    
    
    static let NotificationNameCourseCompleted = NSNotification.Name("CourseCompleted")
    static let NotificationNameCustomRolePlayPrompt = NSNotification.Name("CustomRolePlayPrompt")
    static let NotificationNameUpgradeToPremium = NSNotification.Name("UpgradeToPremium")
    
}

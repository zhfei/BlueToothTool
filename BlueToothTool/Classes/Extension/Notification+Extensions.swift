//
//  NotificationExtensions.swift
//  RepReady
//
//  Created by Cascade on 2024/6/19.
//

import Foundation

extension NSNotification.Name {
    /// Posted when a user completes a lesson
    static let lessonCompleted = NSNotification.Name("LessonCompleted")
    
}

extension NotificationCenter {
    /// Post a lesson completed notification
    static func postLessonCompleted(completedCoursesCount: Int = 0) {
        NotificationCenter.default.post(
            name: .lessonCompleted, 
            object: nil,
            userInfo: ["completedCoursesCount": completedCoursesCount]
        )
    }
    
}

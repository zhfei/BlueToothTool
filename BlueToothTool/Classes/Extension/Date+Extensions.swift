//
//  Date+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension Date {
    func lastYear() -> Date {
        return Calendar.current.date(byAdding: .year, value: -1, to: self)!
    }

    func nextYear() -> Date {
        return Calendar.current.date(byAdding: .year, value: 1, to: self)!
    }

    func lastMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }

    func nextMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    static func dateWithYear(_ year: Int, month: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1  // 默认为每月的第一天
        return calendar.date(from: dateComponents)
    }

    func startAndEndTimestampOfMonth() -> (start: Int64, end: Int64) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let firstDayOfMonth = calendar.date(from: components)!

        var startOfDay = calendar.startOfDay(for: firstDayOfMonth)
        startOfDay.addTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT()))
        let endOfDay = startOfDay.addingTimeInterval(
            86400 * Double(calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 0)
                - 0.001)

        return (Int64(startOfDay.timeIntervalSince1970), Int64(endOfDay.timeIntervalSince1970))
    }

    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format

        return dateFormatter.string(from: self)
    }

    static func fromTimestamp(_ timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    func monthDayHourMinuteDescription() -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)

        return "\(month)/\(day) \(hour):\(minute)"
    }

    func remainingTimeSeconds(until endTimeString: String?) -> Double? {
        guard let endTimeString else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let endTime = dateFormatter.date(from: endTimeString) else {
            return nil
        }

        let timeInterval = endTime.timeIntervalSince(self)
        return timeInterval
    }
}



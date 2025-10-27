//
//  ShortToolMethods.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

let Debug: Bool = {
    let Debug: Bool
    #if DEBUG
        Debug = true
    #else
        Debug = false
    #endif
    return Debug
}()


func showToast(
    _ message: String,
    duration: TimeInterval = ToastManager.shared.duration,
    imageType: Assets.ToastImageType = .none,
    style: ToastStyle = ToastManager.shared.style
) {
    PageManager.getTopViewController()?.showToast(
        message,
        duration: duration,
        imageType: imageType,
        style: style)
}


func keyWindow() -> UIWindow? {
    return UIApplication.shared.currentWindow
}


func printWithTimestamp(_ message: String, functionName: String = #function) {
    guard Debug else {
        return
    }
    let timestampedMessage = "\(functionName): \(message)".timestamped
    print(timestampedMessage)
}

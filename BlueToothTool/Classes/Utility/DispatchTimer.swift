//
//  DispatchTimer.swift
//  RepReady
//
//  Created by Jim Learning on 2023/10/18.
//

import Dispatch

class DispatchTimer {
    private var timer: DispatchSourceTimer?
    
    enum State {
        case idle
        case activing
        case suspended
        case activingByResumed
        case cancled
    }
    
    var state: State = .idle
    
    func start(interval: DispatchTimeInterval, leeway: DispatchTimeInterval = .never, handler: @escaping () -> Void, registrationHandler: (() -> Void)? = nil, cancleHandler: (() -> Void)? = nil) {
        timer?.cancel()
        timer = nil
        
        state = .idle
        
        let queue = DispatchQueue.global()
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: interval, leeway: leeway)
        timer?.setEventHandler(handler: handler)
        if let registrationHandler {
            timer?.setRegistrationHandler(handler: registrationHandler)
        }
        if let cancleHandler {
            timer?.setCancelHandler(handler: cancleHandler)
        }
        timer?.activate()
        
        state = .activing
    }
    
    func asyncAfter(delay: Float, execute: @escaping () -> Void) {
        timer?.cancel()
        timer = nil
        
        state = .idle
        
        let nanoseconds = Int(delay * Float(NSEC_PER_SEC))
        let delayTime = DispatchTime.now() + DispatchTimeInterval.nanoseconds(nanoseconds)
        
        let queue = DispatchQueue.global()
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: delayTime, repeating: .never, leeway: .never)
        timer?.setEventHandler(handler: execute)
        timer?.activate()
        
        state = .activing
    }
    
    func suspend() {
        state = .suspended
        timer?.suspend()
    }
    
    func resume() {
        state = .activingByResumed
        timer?.resume()
    }
    
    func cancel() {
        state = .cancled
        timer?.cancel()
        timer = nil
    }
}

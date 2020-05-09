//
//  PauseableTimer.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

/**
 The timer that can be paused and then resumed from where it was left.
 */
final class PauseableTimer {
    
    private(set) var isPaused = false
    
    private var timer: Timer?
    private var timeLeft: TimeInterval?
    
    /// Schedules the timer with a specified time interval.
    func schedule(with timeInterval: TimeInterval, _ completion: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { (_) in
            self.timer?.invalidate()
            self.timer = nil
            completion()
        })
    }
    
    /// Pauses the timer. It won't fire during pause.
    func pause() {
        guard timer != nil else { return }
        guard !isPaused else { return }
        timeLeft = timer?.fireDate.timeIntervalSinceNow
        timer?.fireDate = Date.distantFuture
        isPaused = true
    }
    
    /// Resumes the timer. It will fire after the time left when it was paused.
    func resume() {
        guard timer != nil else { return }
        guard isPaused else { return }
        guard let timeLeft = timeLeft else { return }
        timer?.fireDate = Date().advanced(by: timeLeft)
        isPaused = false
    }
}

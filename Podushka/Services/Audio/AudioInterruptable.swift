//
//  AudioInterruptable.swift
//  Podushka
//
//  Created by Serhii Kostanian on 10.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

/**
 Simplified audio session interruptions events.
 */
enum InterruptionEvent {
    case began
    case endedWithResume
    case endedWithoutResume
    case unexpected
}

/**
 The extended protocol that handles audio session interruptions and emits simplified events.
 */
protocol AudioInterruptable: AnyObject {
    
    /// PassthroughSubject that emits events when interruption notifications occur.
    var interruptionSubject: PassthroughSubject<InterruptionEvent, Never> { get }
    /// Interruption subscription holder.
    /// - Important: Do not use it! It's made for a default behaviour extention.
    var interruptionSubscription: AnyCancellable? { get set }

    /// Subscribes for audio session interruption events.
    func subsrcibeForInterruptions()
    /// Unsubscribes from audio session interruption events.
    func unsubsrcibeFromInterruptions()
}

extension AudioInterruptable {

    func subsrcibeForInterruptions() {
        interruptionSubscription = NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .sink { (notification) in
                self.handleInterruption(notification)
        }
    }
    
    func unsubsrcibeFromInterruptions() {
        interruptionSubscription?.cancel()
        interruptionSubscription = nil
    }
    
    private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                interruptionSubject.send(.unexpected)
                return
        }
        
        switch type {
        case .began:
            interruptionSubject.send(.began)

        case .ended:
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else { 
                interruptionSubject.send(.unexpected)
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume) {
                interruptionSubject.send(.endedWithResume)
            } else {
                interruptionSubject.send(.endedWithoutResume)
            }
            
        default:
            interruptionSubject.send(.unexpected)
            break
        }
    }

}

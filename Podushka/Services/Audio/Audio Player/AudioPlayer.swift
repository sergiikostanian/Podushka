//
//  AudioPlayer.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

final class AudioPlayer: AudioPlayerService {
    
    var isActive: Bool {
        return player != nil
    }
    
    private var player: AVAudioPlayer?
    private let audioSession = AVAudioSession.sharedInstance()
    
    private let interruptionSubject = PassthroughSubject<InterruptionEvent, Never>()
    private var interruptionSubscription: AnyCancellable?
    
    func play(audio: AudioFile) {
        if player != nil {
            stop()
        }
        
        guard let path = Bundle.main.path(forResource: audio.rawValue, ofType: nil) else { return }

        try? audioSession.setCategory(.playback, options: .duckOthers)
        try? audioSession.setActive(true)
        
        player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        player?.numberOfLoops = -1
        player?.play()
        
        subsrcibeForInterruptions()
    }
    
    func pause() {
        player?.pause()
    }
    
    func resume() {
        player?.play()
    }
    
    func stop() {
        player?.stop()
        player = nil
        unsubsrcibeFromInterruptions()
        try? audioSession.setActive(false)
    }    
    
    func interruptionPublisher() -> AnyPublisher<InterruptionEvent, Never> {
        return interruptionSubject.eraseToAnyPublisher()
    }

}

// MARK: - Helpers
extension AudioPlayer {
    
    private func subsrcibeForInterruptions() {
        interruptionSubscription = NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .sink { (notification) in
                self.handleInterruption(notification)
        }
    }
    
    private func unsubsrcibeFromInterruptions() {
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

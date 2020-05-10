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
    private var subscribers = Set<AnyCancellable>()

    init() {
        try? audioSession.setCategory(.playback, options: .duckOthers)
        registerForInterruptions()
    }
    
    func play(audio: AudioFile) {
        if player != nil {
            stop()
        }
        
        guard let path = Bundle.main.path(forResource: audio.rawValue, ofType: nil) else { return }

        player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        player?.numberOfLoops = -1
        player?.play()
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
    }    
    
    func interruptionPublisher() -> AnyPublisher<InterruptionEvent, Never> {
        return interruptionSubject.eraseToAnyPublisher()
    }

}

// MARK: - Helpers
extension AudioPlayer {
    
    private func registerForInterruptions() {
        NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .sink { (notification) in
                self.handleInterruption(notification)
        }.store(in: &subscribers)
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
                player?.play()
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

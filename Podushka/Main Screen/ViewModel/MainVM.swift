//
//  MainVM.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine

/**
 Main screen View Model implementation.
 */
final class MainVM: MainViewModel {
    
    var sleepTimerDuration: TimeInterval = 0
    var alarmDate: Date = Date().advanced(by: 10 * 60)
    
    // MARK: Dependencies
    private let audioPlayer: AudioPlayerService

    private let stateSubject = CurrentValueSubject<MainState, Never>(.idle)
    private var subscribers = Set<AnyCancellable>()

    init(audioPlayer: AudioPlayerService) {
        self.audioPlayer = audioPlayer
        
        self.audioPlayer.interruptionPublisher().sink { [weak self] (event) in
            self?.hanleAudioInterruption(with: event)
        }.store(in: &subscribers)
    }

    func statePublisher() -> AnyPublisher<MainState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func togglePlaying() {
        switch stateSubject.value {
        case .idle:
            audioPlayer.play(audio: .nature)
            stateSubject.send(.playing)
        case .playing:
            audioPlayer.pause()
            stateSubject.send(.paused)
        case .paused:
            audioPlayer.resume()
            stateSubject.send(.playing)
        default:
            break
        }
    }
}

extension MainVM {
    
    private func hanleAudioInterruption(with event: InterruptionEvent) {
        print(event)
        switch event {
        case .began:
            if stateSubject.value == .playing {
                print("PAUSED")
                stateSubject.send(.paused)
            }
        case .endedWithResume:
            if stateSubject.value == .paused {
                print("PLAYING")
                stateSubject.send(.playing)
            }
        default:
            break
        }
    }
}

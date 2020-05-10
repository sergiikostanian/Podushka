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
    
    var sleepTimerDuration: TimeInterval = 60
    var alarmDate: Date = Date().advanced(by: 10 * 60)
    
    // MARK: Dependencies
    private let audioPlayer: AudioPlayerService
    private let audioRecorder: AudioRecorderService

    private let stateSubject = CurrentValueSubject<MainState, Never>(.idle)
    private var subscribers = Set<AnyCancellable>()
    private var playingTimer = PauseableTimer()

    init(audioPlayer: AudioPlayerService, audioRecorder: AudioRecorderService) {
        self.audioPlayer = audioPlayer
        self.audioRecorder = audioRecorder

        self.audioPlayer.interruptionPublisher().sink { [weak self] (event) in
            self?.hanleAudioInterruption(with: event)
        }.store(in: &subscribers)
    }

    func statePublisher() -> AnyPublisher<MainState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func toggleActivity() {
        switch stateSubject.value {
            
        // Start the entire flow from the beginning. 
        case .idle:
            playingTimer.schedule(with: sleepTimerDuration) { [weak self] in
                // The audio playing stage is completed. Switch to the Recording stage.
                self?.audioPlayer.stop()
                self?.switchToRecordingStage()
            }
            audioPlayer.play(audio: .nature)
            stateSubject.send(.playing)
        
        // Pause playing.
        case .playing:
            playingTimer.pause()
            audioPlayer.pause()
            stateSubject.send(.paused)
            
        // Resume playing or recording.
        case .paused:
            if audioPlayer.isActive {
                playingTimer.resume()
                audioPlayer.resume()
            } else if audioRecorder.isActive {
                audioRecorder.resume()
            }
            stateSubject.send(.playing)
            
        // Pause recording.
        case .recording:
            audioRecorder.pause()
            stateSubject.send(.paused)
            
        // Do nothing, toggling during alarm state is forbidden.
        case .alarm:
            break
        }
    }
}

extension MainVM {
    
    private func switchToRecordingStage() {
        audioRecorder.start()
        stateSubject.send(.recording)
    }
    
    private func hanleAudioInterruption(with event: InterruptionEvent) {
        switch event {
        case .began:
            if stateSubject.value == .playing {
                stateSubject.send(.paused)
            }
        case .endedWithResume:
            if stateSubject.value == .paused {
                stateSubject.send(.playing)
            }
        default: break
        }
    }
}

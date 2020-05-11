//
//  MainVM.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine
import UserNotifications

/**
 Main screen View Model implementation.
 */
final class MainVM: MainViewModel {
    
    var sleepTimerDuration: TimeInterval = 60
    var alarmDate: Date = Date().advanced(by: 5 * 60).withoutSeconds
    
    // MARK: Dependencies
    private let audioService: AudioService

    // MARK: Subscriptions
    private let stateSubject = CurrentValueSubject<MainState, Never>(.idle)
    private var subscribers = Set<AnyCancellable>()
    
    // MARK: Timers
    private var playingTimer = PauseableTimer()
    private var alarmTimer = PauseableTimer()

    init(audioService: AudioService) {
        self.audioService = audioService

        self.audioService.interruptionSubject.sink { [weak self] (event) in
            self?.hanleAudioInterruption(with: event)
        }.store(in: &subscribers)
    }
    
    deinit {
        subscribers.forEach({ $0.cancel() })
        subscribers.removeAll()
    }

    func statePublisher() -> AnyPublisher<MainState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func toggleActivity() {
        switch stateSubject.value {
            
        // Start the entire flow from the beginning. 
        case .idle:
            audioService.startSession()
            scheduleAlarm()

            // Switch to the recording stage immediately if the sleep timer if off.
            guard sleepTimerDuration > 0 else {
                stateSubject.send(.recording)
                break
            }
            
            scheduleSleep()
            audioService.play(audio: .nature)
            audioService.setRemoteCommandCenter(enabled: true)
            audioService.startRecording()
            stateSubject.send(.playing)
        
        // Pause playing.
        case .playing:
            playingTimer.pause()
            audioService.pausePlaying()
            audioService.pauseRecording()
            stateSubject.send(.paused)
            
        // Resume playing or recording.
        case .paused:
            audioService.resumePlaying()
            audioService.resumeRecording()
            if audioService.isPlaying {
                playingTimer.resume()
                stateSubject.send(.playing)
            } else if audioService.isRecording {
                stateSubject.send(.recording)
            }
            
        // Pause recording.
        case .recording:
            audioService.pauseRecording()
            stateSubject.send(.paused)
            
        // Do nothing, toggling during alarm state is forbidden.
        case .alarm:
            break
        }
    }
    
    func resetFlow() {
        audioService.stopPlaying()
        audioService.stopSession()
        stateSubject.send(.idle)
    }
    
}

extension MainVM {
    
    private func scheduleAlarm() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge]) { granted, error in
            guard granted, error == nil else { return }

            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "Rise and shine!"

            let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: self.alarmDate)        
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)        
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            center.add(request)
        }
        
        let timeInterval = alarmDate.timeIntervalSince(Date())
        alarmTimer.schedule(with: timeInterval) { [weak self] in
            guard let strongSelf = self else { return }
            // The audio recording stage is completed. Switch to the alarm stage.
            strongSelf.audioService.stopRecording()
            strongSelf.audioService.setRemoteCommandCenter(enabled: false)
            strongSelf.audioService.play(audio: .alarm)
            strongSelf.stateSubject.send(.alarm)
        }
    }
    
    private func scheduleSleep() {
        playingTimer.schedule(with: sleepTimerDuration) { [weak self] in
            guard let strongSelf = self else { return }
            guard strongSelf.stateSubject.value == .playing else { return }
            // The audio playing stage is completed. Switch to the Recording stage.
            strongSelf.audioService.stopPlaying()
            strongSelf.audioService.setRemoteCommandCenter(enabled: false)
            strongSelf.stateSubject.send(.recording)
        }
    }
    
    private func hanleAudioInterruption(with event: InterruptionEvent) {
        switch event {
        case .began:
            if stateSubject.value == .playing {
                playingTimer.pause()
                audioService.pausePlaying()
                audioService.pauseRecording()
            } else if stateSubject.value == .recording {
                audioService.pauseRecording()
            }
            stateSubject.send(.paused)
            
        case .endedWithResume:
            if stateSubject.value == .paused {
                audioService.resumePlaying()
                audioService.resumeRecording()
                if audioService.isPlaying {
                    playingTimer.resume()
                    stateSubject.send(.playing)
                } else if audioService.isRecording {
                    stateSubject.send(.recording)
                }
            }
            
        default: break
        }
    }
}

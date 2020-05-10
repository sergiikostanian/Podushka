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
final class MainVM: NSObject, MainViewModel {
    
    var sleepTimerDuration: TimeInterval = 60
    var alarmDate: Date = Date().advanced(by: 10 * 60)
    
    // MARK: Dependencies
    private let audioPlayer: AudioPlayerService
    private let audioRecorder: AudioRecorderService

    private let stateSubject = CurrentValueSubject<MainState, Never>(.idle)
    private var subscribers = Set<AnyCancellable>()
    private var playingTimer = PauseableTimer()
    private var alarmTimer = PauseableTimer()

    init(audioPlayer: AudioPlayerService, audioRecorder: AudioRecorderService) {
        self.audioPlayer = audioPlayer
        self.audioRecorder = audioRecorder
        
        super.init()

        self.audioPlayer.interruptionSubject.sink { [weak self] (event) in
            self?.hanleAudioInterruption(with: event)
        }.store(in: &subscribers)
        
        self.audioRecorder.interruptionSubject.sink { [weak self] (event) in
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
            scheduleAlarm()

            // Switch to the recording stage immediately if the sleep timer if off.
            guard sleepTimerDuration > 0 else {
                switchToRecordingStage()
                break
            }
            
            playingTimer.schedule(with: sleepTimerDuration) { [weak self] in
                guard let strongSelf = self else { return }
                guard strongSelf.stateSubject.value == .playing else { return }
                // The audio playing stage is completed. Switch to the Recording stage.
                strongSelf.audioPlayer.stop()
                strongSelf.switchToRecordingStage()
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
                stateSubject.send(.playing)
            } else if audioRecorder.isActive {
                audioRecorder.resume()
                stateSubject.send(.recording)
            }
            
        // Pause recording.
        case .recording:
            audioRecorder.pause()
            stateSubject.send(.paused)
            
        // Do nothing, toggling during alarm state is forbidden.
        case .alarm:
            break
        }
    }
    
    func resetFlow() {
        audioPlayer.stop()
        stateSubject.send(.idle)
    }
    
}

extension MainVM {
    
    private func scheduleAlarm() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted, error == nil else { return }

            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "Rise and shine!"
            content.sound = .default

            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: self.alarmDate)        
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)        
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            center.add(request)
        }
    }
    
    private func switchToRecordingStage() {
        audioRecorder.start()
        stateSubject.send(.recording)
    }
    
    private func hanleAudioInterruption(with event: InterruptionEvent) {
        switch event {
        case .began:
            if stateSubject.value == .playing {
                playingTimer.pause()
                audioPlayer.pause()
            } else if stateSubject.value == .recording {
                audioRecorder.pause()
                stateSubject.send(.paused)
            }
            
        case .endedWithResume:
            if stateSubject.value == .paused {
                if audioPlayer.isActive {
                    playingTimer.resume()
                    audioPlayer.resume()
                    stateSubject.send(.playing)
                } else if audioRecorder.isActive {
                    audioRecorder.resume()
                    stateSubject.send(.recording)
                }
            }
            
        default: break
        }
    }
}

extension MainVM: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Alarm notification was triggered in the foreground.
        audioRecorder.stop()
        audioPlayer.play(audio: .alarm)
        stateSubject.send(.alarm)
    }
}


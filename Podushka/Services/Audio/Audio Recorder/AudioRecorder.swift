//
//  AudioRecorder.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

final class AudioRecorder: AudioRecorderService {
    
    var isActive: Bool {
        return audioRecorder != nil
    }
    
    private var audioRecorder: AVAudioRecorder?
    private let audioSession = AVAudioSession.sharedInstance()

    private let interruptionSubject = PassthroughSubject<InterruptionEvent, Never>()
    private var interruptionSubscription: AnyCancellable?

    func start() {
        audioSession.requestRecordPermission() { [weak self] granted in
            guard granted else { return }
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                try? strongSelf.audioSession.setCategory(.playAndRecord, mode: .default)
                try? strongSelf.audioSession.setActive(true)

                let audioFilename = strongSelf.documentsDirectory.appendingPathComponent("\(Date()).m4a")
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                    AVNumberOfChannelsKey: 1
                ]

                strongSelf.audioRecorder = try? AVAudioRecorder(url: audioFilename, settings: settings)
                strongSelf.audioRecorder?.record()
                strongSelf.subsrcibeForInterruptions()
            }
        }
    }
    
    func pause() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        recorder.pause()
    }
    
    func resume() {
        guard let recorder = audioRecorder, !recorder.isRecording else { return }
        recorder.record()
    }
    
    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
        unsubsrcibeFromInterruptions()
        try? audioSession.setActive(false)
    }
    
    func interruptionPublisher() -> AnyPublisher<InterruptionEvent, Never> {
        return interruptionSubject.eraseToAnyPublisher()
    }

}

extension AudioRecorder {
    
    private var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

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
                audioRecorder?.record()
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

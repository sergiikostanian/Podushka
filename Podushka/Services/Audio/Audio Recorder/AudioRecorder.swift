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
    
    let interruptionSubject = PassthroughSubject<InterruptionEvent, Never>()
    var interruptionSubscription: AnyCancellable?
    
    private var audioRecorder: AVAudioRecorder?
    private let audioSession = AVAudioSession.sharedInstance()

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
                    AVSampleRateKey: 12000,
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

}

extension AudioRecorder {
    
    private var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

}

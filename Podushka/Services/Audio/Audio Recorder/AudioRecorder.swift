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
        if audioSession.recordPermission == .granted {
            startRecording()
            return
        }
        
        audioSession.requestRecordPermission() { [weak self] granted in
            guard granted else { return }
            DispatchQueue.main.async {
                self?.startRecording()
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
    
    private func startRecording() {
        try? audioSession.setCategory(.playAndRecord, mode: .default)
        try? audioSession.setActive(true)

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsDirectory.appendingPathComponent("\(Date()).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1
        ]

        audioRecorder = try? AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.record()
        subsrcibeForInterruptions()
    }
}

//
//  AudioRecorder.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioRecorder: AudioRecorderService {
    
    var isActive: Bool {
        return audioRecorder != nil
    }
    
    private var audioRecorder: AVAudioRecorder?
    private let audioSession = AVAudioSession.sharedInstance()

    func start() {
        try? audioSession.setCategory(.playAndRecord, mode: .default)
        try? audioSession.setActive(true)
        
        audioSession.requestRecordPermission() { [weak self] granted in
            guard granted else { return }
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                let audioFilename = strongSelf.documentsDirectory.appendingPathComponent("\(Date()).m4a")
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                    AVNumberOfChannelsKey: 1
                ]

                strongSelf.audioRecorder = try? AVAudioRecorder(url: audioFilename, settings: settings)
                strongSelf.audioRecorder?.record()
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
        try? audioSession.setActive(false)
    }
    
}

extension AudioRecorder {
    
    private var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

}

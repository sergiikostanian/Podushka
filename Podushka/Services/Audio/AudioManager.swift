//
//  AudioManager.swift
//  Podushka
//
//  Created by Serhii Kostanian on 11.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

final class AudioManager: AudioService {
    
    var isPlaying: Bool { 
        return player != nil
    }
    var isRecording: Bool { 
        return recorder != nil
    }

    let interruptionSubject = PassthroughSubject<InterruptionEvent, Never>()
    var interruptionSubscription: AnyCancellable?
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder?
    
    private var playCommandTarget: Any?
    private var pauseCommandTarget: Any?
    private var currentRecordingTitle: String?

    // MARK: - Session
    func startSession() {
        try? audioSession.setCategory(.playAndRecord, mode: .default)
        try? audioSession.setActive(true)
        subsrcibeForInterruptions()
    }
    
    func stopSession() {
        try? audioSession.setActive(false)
        unsubsrcibeFromInterruptions()
    }
    
    // MARK: - Audio Playing
    func play(audio: AudioFile) {
        if player != nil {
            stopPlaying()
        }
        
        guard let path = Bundle.main.path(forResource: audio.rawValue, ofType: nil) else { return }

        player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        player?.numberOfLoops = -1
        player?.play()
    }
    
    func pausePlaying() {
        guard let player = player, player.isPlaying else { return }
        player.pause()
    }
    
    func resumePlaying() {
        guard let player = player, !player.isPlaying else { return }
        player.play()
    }
    
    func stopPlaying() {
        player?.stop()
        player = nil
    }
    
    // MARK: - Audio Recording
    func startDummyRecording() {
        currentRecordingTitle = "\(Date()).m4a"

        if audioSession.recordPermission == .granted {
            launchAudioRecorder(with: currentRecordingTitle!)
            return
        }
        
        audioSession.requestRecordPermission() { [weak self] granted in
            guard let strongSelf = self, granted else { return }
            guard let title = strongSelf.currentRecordingTitle else { return }
            DispatchQueue.main.async {
                strongSelf.launchAudioRecorder(with: title)
            }
        }
    }
    
    func startRecording() {
        let title = currentRecordingTitle ?? "\(Date()).m4a"
        
        if audioSession.recordPermission == .granted {
            launchAudioRecorder(with: title)
            return
        }
        
        audioSession.requestRecordPermission() { [weak self] granted in
            guard let strongSelf = self, granted else { return }
            DispatchQueue.main.async {
                strongSelf.launchAudioRecorder(with: title)
            }
        }
    }
    
    func pauseRecording() {
        guard let recorder = recorder, recorder.isRecording else { return }
        recorder.pause()
    }
    
    func resumeRecording() {
        guard let recorder = recorder, !recorder.isRecording else { return }
        recorder.record()
    }
    
    func stopRecording() {
        recorder?.stop()
        recorder = nil
        currentRecordingTitle = nil
    }
    
    func setRemoteCommandCenter(enabled: Bool) {
        let center = MPRemoteCommandCenter.shared()
        if enabled {
            let center = MPRemoteCommandCenter.shared()
            playCommandTarget = center.playCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
                guard let player = self.player else { return .noActionableNowPlayingItem }
                if !player.isPlaying {
                    self.resumePlaying()
                    return .success
                }
                return .commandFailed
            }
            pauseCommandTarget = center.pauseCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
                guard let player = self.player else { return .noActionableNowPlayingItem }
                if player.isPlaying {
                    self.pausePlaying()
                    return .success
                }
                return .commandFailed
            }
        } else {
            center.playCommand.removeTarget(playCommandTarget)
            center.pauseCommand.removeTarget(pauseCommandTarget)
        }
        center.playCommand.isEnabled = enabled
        center.pauseCommand.isEnabled = enabled
    }
    
}

// MARK: - Helpers
extension AudioManager {
    
    private func launchAudioRecorder(with title: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsDirectory.appendingPathComponent(title)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1
        ]

        recorder = try? AVAudioRecorder(url: audioFilename, settings: settings)
        recorder?.record()
    }
    
}

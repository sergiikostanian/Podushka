//
//  AudioService.swift
//  Podushka
//
//  Created by Serhii Kostanian on 11.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine

enum AudioFile: String {
    case nature = "nature.m4a"
    case alarm = "alarm.m4a"
}

protocol AudioService: AudioInterruptable {
    
    /// Indicates whether the audio is playing. Returns `true` If it's playing or paused playing.
    var isPlaying: Bool { get }
    /// Indicates whether the audio is recording. Returns `true` If it's recoring or paused recording.
    var isRecording: Bool { get }
    
    /// Starts audio session.
    /// - Important: You must call this method before start playing recording audio.
    func startSession()
    /// Stops audio session.
    /// - Important: You must call this method when you finished playing and/or recording audio.
    func stopSession()
    
    /// Starts playing specified audio file.
    func play(audio: AudioFile)
    /// Pauses playing current audio file.
    func pausePlaying()
    /// Resumes playing current audio file.
    func resumePlaying()
    /// Stops playing current audio file.
    func stopPlaying()
    
    /// This is a workaroud method to enable start recording in the background.
    /// Since iOS 12.4 it is impossible to start recording while your app is in the background.
    /// To fix this we can start dummy recording while in the foreground and then,
    /// after starting the real recording by calling `startRecording()` we can overwrite dummy record.
    /// For more details, read [this thread](https://forums.developer.apple.com/thread/120038).
    func startDummyRecording()
    
    /// Starts recording audio.
    func startRecording()
    /// Pauses current recording.
    func pauseRecording()
    /// Resumes current recording.
    func resumeRecording()
    /// Stops current recording.
    func stopRecording()
    
    /// Enabled or disables remote command center contolling play and pause actions for currently playing audio.
    func setRemoteCommandCenter(enabled: Bool)
    
}

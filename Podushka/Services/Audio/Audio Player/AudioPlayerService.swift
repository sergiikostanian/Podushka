//
//  AudioPlayerService.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine

enum AudioFile: String {
    case nature = "nature.m4a"
    case alarm = "alarm.m4a"
}

protocol AudioPlayerService: AudioInterruptable {
    
    /// Indicates whether the audio player service is acitve. Returns `true` If it's playing or paused.
    var isActive: Bool { get }
    
    /// Starts playing specified audio file.
    func play(audio: AudioFile)
    /// Pauses playing current audio file.
    func pause()
    /// Resumes playing current audio file.
    func resume()
    /// Stops playing current audio file.
    func stop()
    
}

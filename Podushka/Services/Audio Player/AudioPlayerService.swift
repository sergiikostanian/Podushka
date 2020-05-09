//
//  AudioPlayerService.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

enum AudioFile: String {
    case nature = "nature.m4a"
    case alarm = "alarm.m4a"
}

protocol AudioPlayerService {
    
    /// Starts playing specified audio file.
    func play(audio: AudioFile)
    /// Pauses playing current audio file.
    func pause()
    /// Resumes playing current audio file.
    func resume()
    /// Stops playing current audio file.
    func stop()
    
}

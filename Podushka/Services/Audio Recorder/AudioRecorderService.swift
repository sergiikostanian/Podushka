//
//  AudioRecorderService.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

protocol AudioRecorderService {
    
    /// Starts recording audio.
    func start()
    /// Pauses current recording.
    func pause()
    /// Resumes current recording.
    func resume()
    /// Stops current recording.
    func stop()
    
}

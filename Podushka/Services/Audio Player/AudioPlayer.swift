//
//  AudioPlayer.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioPlayer: AudioPlayerService {
    
    private var player: AVAudioPlayer?
    private let audioSession = AVAudioSession.sharedInstance()

    init() {
        try? audioSession.setCategory(.playback, options: .duckOthers)
    }
    
    func play(audio: AudioFile) {
        if player != nil {
            stop()
        }
        
        guard let path = Bundle.main.path(forResource: audio.rawValue, ofType: nil) else { return }

        player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        player?.numberOfLoops = -1
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func resume() {
        player?.play()
    }
    
    func stop() {
        player?.stop()
        player = nil
    }
}

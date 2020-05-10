//
//  AudioPlayer.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

final class AudioPlayer: AudioPlayerService {
    
    var isActive: Bool {
        return player != nil
    }
    
    let interruptionSubject = PassthroughSubject<InterruptionEvent, Never>()
    var interruptionSubscription: AnyCancellable?
    
    private var player: AVAudioPlayer?
    private let audioSession = AVAudioSession.sharedInstance()
    
    func play(audio: AudioFile) {
        if player != nil {
            stop()
        }
        
        guard let path = Bundle.main.path(forResource: audio.rawValue, ofType: nil) else { return }

        try? audioSession.setCategory(.playback, options: .duckOthers)
        try? audioSession.setActive(true)
        
        player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        player?.numberOfLoops = -1
        player?.play()
        
        subsrcibeForInterruptions()
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
        unsubsrcibeFromInterruptions()
        try? audioSession.setActive(false)
    }    
    
}

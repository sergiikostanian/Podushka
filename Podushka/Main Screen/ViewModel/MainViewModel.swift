//
//  MainViewModel.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine

enum MainState {
    case idle
    case playing
    case recording
    case paused
    case alarm
}

/**
 Main screen View Model protocol.
 */
protocol MainViewModel {
        
    /// The pre-sleep audio duration. Set `0` to skip.
    var sleepTimerDuration: TimeInterval { get set }
    
    /// The alarm fire time. The alarm sound will start playing and the alert popup will be displayed at the specified time.
    /// If the application is in background when the alarm went off, the local notification about the alarm will be shown.
    var alarmDate: Date { get set }
        
    /// The main state publisher.
    func statePublisher() -> AnyPublisher<MainState, Never>
}

//
//  BackgroundManager.swift
//  Podushka
//
//  Created by Serhii Kostanian on 10.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine

final class BackgroundManager: BackgroundService { 
    
    private let alarmBackgroundTaskSubject = PassthroughSubject<Void, Never>()

    func alarmBackgroundTaskPublisher() -> AnyPublisher<Void, Never> {
        alarmBackgroundTaskSubject.eraseToAnyPublisher()
    }
    
    func handleAlarmBackgroundTask() {
        alarmBackgroundTaskSubject.send()
    }
}

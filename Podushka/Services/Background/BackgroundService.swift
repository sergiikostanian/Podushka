//
//  BackgroundService.swift
//  Podushka
//
//  Created by Serhii Kostanian on 10.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine

protocol BackgroundService {
    func alarmBackgroundTaskPublisher() -> AnyPublisher<Void, Never>
    func handleAlarmBackgroundTask()
}

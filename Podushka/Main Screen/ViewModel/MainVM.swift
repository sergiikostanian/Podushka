//
//  MainVM.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation
import Combine

/**
 Main screen View Model implementation.
 */
final class MainVM: MainViewModel{
    
    var sleepTimerDuration: TimeInterval = 0
    var alarmDate: Date = Date().advanced(by: 10 * 60)
    
    // MARK: Dependencies
    private let dependencyManager: DependencyManager

    init(dependencyManager: DependencyManager) {
        self.dependencyManager = dependencyManager
    }

    private let stateSubject = CurrentValueSubject<MainState, Never>(.idle)
    func statePublisher() -> AnyPublisher<MainState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
}

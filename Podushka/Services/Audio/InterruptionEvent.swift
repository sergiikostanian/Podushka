//
//  InterruptionEvent.swift
//  Podushka
//
//  Created by Serhii Kostanian on 10.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

enum InterruptionEvent {
    case began
    case endedWithResume
    case endedWithoutResume
    case unexpected
}

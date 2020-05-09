//
//  TimeFormatter.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

extension Formatter {
    
    /// A simple `DateFormatter` that represents time in a short format.
    /// Example string representation: 3:30 PM.
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
}

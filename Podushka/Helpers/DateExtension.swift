//
//  DateExtension.swift
//  Podushka
//
//  Created by Serhii Kostanian on 11.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

extension Date {

    /// Returns date with seconds set to 0.
    var withoutSeconds: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: dateComponents)!
    }

}

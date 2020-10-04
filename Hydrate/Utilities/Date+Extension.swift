//
//  Date+Extension.swift
//  Hydrate
//
//  Created by David Wright on 9/14/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

extension Date {
    
    static var today: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        return calendar.date(from: components)!
    }
    
    var startOfDay: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }
    
    var startOfNextDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }
    
    var dayComponent: Int {
        Calendar.current.dateComponents([.day], from: self).day!
    }
    
    var isInCurrentDay: Bool {
        isEqual(to: Date(), toGranularity: .day)
    }
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    func isInSameDayAs(date: Date) -> Bool {
        isEqual(to: date, toGranularity: .day)
    }
}

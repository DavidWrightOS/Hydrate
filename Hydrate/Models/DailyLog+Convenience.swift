//
//  DailyLog+Convenience.swift
//  Hydrate
//
//  Created by David Wright on 9/29/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation
import CoreData

extension DailyLog {
    
    @discardableResult
    convenience init(date: Date = Date(),
                     intakeEntries: [IntakeEntry]? = nil,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.date = date.startOfDay
    }
}

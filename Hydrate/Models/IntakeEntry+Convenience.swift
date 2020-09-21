//
//  IntakeEntry+Convenience.swift
//  Hydrate
//
//  Created by David Wright on 9/21/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation
import CoreData

extension IntakeEntry {
    
    @discardableResult
    convenience init(intakeAmount: Int,
                     timestamp: Date = Date(),
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.amount = Int64(intakeAmount)
        self.timestamp = timestamp
        self.identifier = identifier
    }
    
    static func ==(lhs: IntakeEntry, rhs: IntakeEntry) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

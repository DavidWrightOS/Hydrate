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
                     dailyLog: DailyLog? = nil,
                     timestamp: Date = Date(),
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.amount = Int64(intakeAmount)
        self.timestamp = timestamp
        self.day = timestamp.startOfDay
        self.identifier = identifier
        
        if let dailyLog = dailyLog {
            self.dailyLog = dailyLog
        } else {
            let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
            let datePredicate = NSPredicate(format: "(%K = %@)", #keyPath(DailyLog.date), timestamp.startOfDay as NSDate)
            fetchRequest.predicate = datePredicate
            
            do {
                let dailyLog = try CoreDataStack.shared.mainContext.fetch(fetchRequest).first
                self.dailyLog = dailyLog ?? DailyLog(date: timestamp.startOfDay)
                CoreDataStack.shared.saveContext()
            } catch let error as NSError {
                print("Error fetching: \(error), \(error.userInfo)")
            }
        }
    }
        
    static func ==(lhs: IntakeEntry, rhs: IntakeEntry) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

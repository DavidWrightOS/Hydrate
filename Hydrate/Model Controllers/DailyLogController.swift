//
//  DailyLogController.swift
//  Hydrate
//
//  Created by David Wright on 10/2/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation
import CoreData

class DailyLogController {
    
    // MARK: - Properties
    
    lazy var coreDataStack = CoreDataStack.shared
    
    // MARK: - Methods
    
    func dailyLog(for date: Date = Date()) -> DailyLog {
        let day = date.startOfDay
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        let datePredicate = NSPredicate(format: "(%K = %@)", #keyPath(DailyLog.date), day as NSDate)
        fetchRequest.predicate = datePredicate
        
        do {
            let dailyLog = try CoreDataStack.shared.mainContext.fetch(fetchRequest).first
            if let dailyLog = dailyLog {
                return dailyLog
            }
        } catch let error as NSError {
            print("Error fetching: \(error), \(error.userInfo)")
        }
        
        let dailyLog = DailyLog(date: day)
        coreDataStack.saveContext()
        
        return dailyLog
    }
    
    func addIntakeEntry(intakeAmount: Int) {
        IntakeEntry(intakeAmount: intakeAmount)
        coreDataStack.saveContext()
    }
    
    func delete(_ intakeEntry: IntakeEntry) {
        coreDataStack.mainContext.delete(intakeEntry)
        coreDataStack.saveContext()
    }
}

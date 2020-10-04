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
    
    private lazy var coreDataStack = CoreDataStack.shared
    
    // MARK: - Methods
    
    func fetchDailyLog(for date: Date = Date()) -> DailyLog {
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
    
    func add(intakeAmount: Int, to dailyLog: DailyLog? = nil) {
        let dailyLog = dailyLog ?? fetchDailyLog()
        IntakeEntry(intakeAmount: intakeAmount, dailyLog: dailyLog)
        coreDataStack.saveContext()
    }
    
    func delete(_ dailyLog: DailyLog) {
        coreDataStack.mainContext.delete(dailyLog)
        coreDataStack.saveContext()
    }
    
    func delete(_ intakeEntry: IntakeEntry, from dailyLog: DailyLog? = nil) {
        let dailyLog = dailyLog ?? fetchDailyLog()
        dailyLog.removeFromIntakeEntries(intakeEntry)
        coreDataStack.mainContext.delete(intakeEntry)
        coreDataStack.saveContext()
    }
}

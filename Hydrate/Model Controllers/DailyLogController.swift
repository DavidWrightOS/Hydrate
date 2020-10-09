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
    
    var dailyLog: DailyLog?
    
    var lastIntakeEntryAddedToday: IntakeEntry? {
        guard let dailyLog = dailyLog else { return nil }
        return fetchIntakeEntries(for: dailyLog.date!)?.first
    }
    
    private lazy var coreDataStack = CoreDataStack.shared
    
    // MARK: - Methods
    
    func loadDailyLog(for date: Date = Date()) {
        dailyLog = fetchDailyLog(for: date)
    }
    
    func fetchDailyLog(for date: Date = Date()) -> DailyLog? {
        let day = date.startOfDay
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        let datePredicate = NSPredicate(format: "(%K = %@)", #keyPath(DailyLog.date), day as NSDate)
        fetchRequest.predicate = datePredicate
        
        do {
            let dailyLog = try coreDataStack.mainContext.fetch(fetchRequest).first
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
    
    func fetchIntakeEntries(for date: Date = Date()) -> [IntakeEntry]? {
        let fetchRequest: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        let datePredicate = NSPredicate(format: "(%K >= %@) AND (%K < %@)",
                                        #keyPath(IntakeEntry.timestamp), date.startOfDay as NSDate,
                                        #keyPath(IntakeEntry.timestamp), date.startOfNextDay as NSDate)
        fetchRequest.predicate = datePredicate
        
        let sortDescriptor = NSSortDescriptor(keyPath: \IntakeEntry.timestamp, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let intakeEntries = try coreDataStack.mainContext.fetch(fetchRequest)
            return intakeEntries
        } catch let error as NSError {
            print("Error fetching intakeEntries: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func fetchIntakeEntries(for dailyLog: DailyLog) -> [IntakeEntry] {
        let fetchRequest: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        let datePredicate = NSPredicate(format: "(%K == %@)", #keyPath(IntakeEntry.dailyLog), dailyLog)
        fetchRequest.predicate = datePredicate
        
        let sortDescriptor = NSSortDescriptor(keyPath: \IntakeEntry.timestamp, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let intakeEntries = try coreDataStack.mainContext.fetch(fetchRequest)
            return intakeEntries
        } catch let error as NSError {
            print("Error fetching intakeEntries: \(error), \(error.userInfo)")
            return []
        }
    }
    
    func add(intakeAmount: Int) {
        if dailyLog == nil {
            dailyLog = fetchDailyLog() ?? DailyLog()
        }
        
        IntakeEntry(intakeAmount: intakeAmount, dailyLog: dailyLog)
        coreDataStack.saveContext()
        sendNotificationIfNeeded()
    }
    
    func delete(_ dailyLog: DailyLog) {
        if self.dailyLog?.date == dailyLog.date {
            self.dailyLog = nil
        }
        coreDataStack.mainContext.delete(dailyLog)
        coreDataStack.saveContext()
        sendNotificationIfNeeded()
    }
    
    func undoLastIntakeEntry() -> Int {
        guard let dailyLog = dailyLog, let intakeEntry = lastIntakeEntryAddedToday else { return 0 }
        let intakeAmount = Int(intakeEntry.amount)
        coreDataStack.mainContext.delete(intakeEntry)
        
        if dailyLog.intakeEntries?.count == 0 {
            coreDataStack.mainContext.delete(dailyLog)
        }
        
        coreDataStack.saveContext()
        
        return intakeAmount
    }
    
    func delete(_ intakeEntry: IntakeEntry) {
        guard let dailyLog = intakeEntry.dailyLog else {
            coreDataStack.mainContext.delete(intakeEntry)
            coreDataStack.saveContext()
            return
        }
        
        dailyLog.removeFromIntakeEntries(intakeEntry)
        coreDataStack.mainContext.delete(intakeEntry)
        
        if dailyLog.intakeEntries?.count == 0 {
            coreDataStack.mainContext.delete(dailyLog)
        }
        
        coreDataStack.saveContext()
        
        if dailyLog.date == self.dailyLog?.date {
            self.dailyLog = dailyLog
        }
        
        sendNotificationIfNeeded()
    }
    
    fileprivate func sendNotificationIfNeeded() {
        guard let date = dailyLog?.date else {
            NotificationCenter.default.post(Notification(name: .todaysDailyLogDidUpdateNotificationName))
            return
        }
        
        if date.isInCurrentDay {
            NotificationCenter.default.post(Notification(name: .todaysDailyLogDidUpdateNotificationName))
        }
    }
}

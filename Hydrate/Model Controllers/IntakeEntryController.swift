//
//  IntakeEntryController.swift
//  Hydrate
//
//  Created by David Wright on 10/7/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation
import CoreData

class IntakeEntryController {
    
    // MARK: - Properties
    
    private(set) var intakeEntries: [IntakeEntry] = [] {
        didSet {
            sendIntakeEntriesDidChangeNotification()
        }
    }
    
    var totalIntake: Int {
        Int(intakeEntries.reduce(0) { $0 + $1.amount })
    }
    
    private lazy var coreDataStack = CoreDataStack.shared
    
    // MARK: - Methods
    
    func loadIntakeEntries(for date: Date = Date()) {
        intakeEntries = fetchIntakeEntries(for: date)
    }
    
    func fetchIntakeEntries(for date: Date = Date()) -> [IntakeEntry] {
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
            return []
        }
    }
    
    @discardableResult
    func addIntakeEntry(amount intakeAmount: Int) -> IntakeEntry {
        let intakeEntry = IntakeEntry(intakeAmount: intakeAmount)
        coreDataStack.saveContext()
        
        if intakeEntry.timestamp!.isInCurrentDay {
            intakeEntries.insert(intakeEntry, at: 0)
        }
        
        return intakeEntry
    }
    
    func delete(_ intakeEntry: IntakeEntry) {
        coreDataStack.mainContext.delete(intakeEntry)
        coreDataStack.saveContext()
        
        if intakeEntry.timestamp!.isInCurrentDay {
            intakeEntries.removeAll(where: { $0 == intakeEntry })
        }
    }
    
    fileprivate func sendIntakeEntriesDidChangeNotification() {
        NotificationCenter.default.post(Notification(name: .intakeEntriesDidChangeNotificationName))
    }
}

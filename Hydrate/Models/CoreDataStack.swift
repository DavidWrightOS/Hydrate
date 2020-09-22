//
//  CoreDataStack.swift
//  Hydrate
//
//  Created by David Wright on 9/21/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    private init() {}
    
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Hydrate")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        guard mainContext.hasChanges else { return }
        
        mainContext.performAndWait {
            do {
                try mainContext.save()
            } catch let error as NSError {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

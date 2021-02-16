//
//  ProfileDataStore.swift
//  Hydrate
//
//  Created by David Wright on 2/15/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import HealthKit

class ProfileDataStore {
    
    /// This method will throw an error if the date of birth or biological sex haven’t been saved in HealthKit’s central repository
    class func getAgeAndSexType() throws -> (age: Int, biologicalSex: HKBiologicalSex) {
        
        let healthKitStore = HKHealthStore()
        
        do {
            let birthdayComponents = try healthKitStore.dateOfBirthComponents()
            let biologicalSex = try healthKitStore.biologicalSex()
            
            /// Use Calendar to calculate age.
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year], from: today)
            let thisYear = todayDateComponents.year!
            let age = thisYear - birthdayComponents.year!
            
            /// Unwrap the wrappers to get the underlying enum values.
            let unwrappedBiologicalSex = biologicalSex.biologicalSex
            
            return (age, unwrappedBiologicalSex)
        }
    }
}

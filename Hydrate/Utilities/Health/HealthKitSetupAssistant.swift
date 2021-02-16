//
//  HealthKitSetupAssistant.swift
//  Hydrate
//
//  Created by David Wright on 2/14/21.
//  Copyright © 2021 David Wright. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool) -> Void) {
        
        // Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            handleError(message: "HealthKit Authorization Failed", error: HealthkitSetupError.notAvailableOnDevice)
            completion(false)
            return
        }
        
        // Prepare the data types that will interact with HealthKit
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
              let height = HKObjectType.quantityType(forIdentifier: .height),
              let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let dietaryWater = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            handleError(message: "HealthKit Authorization Failed", error: HealthkitSetupError.dataTypeNotAvailable)
            completion(false)
            return
        }
        
        // Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [dietaryWater]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       biologicalSex,
                                                       height,
                                                       bodyMass,
                                                       dietaryWater]
        
        // Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            
            if !success {
                handleError(message: "HealthKit Authorization Failed", error: error)
            }
            
            completion(success)
        }
    }
    
    private class func handleError(message: String, error: Error? = nil) {
        if let error = error {
            NSLog("\(message). Reason: \(error.localizedDescription)")
        } else {
            NSLog(message)
        }
    }
}

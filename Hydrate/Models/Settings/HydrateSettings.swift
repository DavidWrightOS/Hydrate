//
//  HydrateSettings.swift
//  Hydrate
//
//  Created by David Wright on 10/14/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let settingsChanged = Notification.Name("SettingsChanged")
}

@objc protocol SettingsTracking {
    @objc func settingsDataChanged()
}

extension SettingsTracking {
    func registerForSettingsChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDataChanged), name: .settingsChanged, object: nil)
    }
}

@objc protocol SettingsConfigurable {
    static var targetDailyIntake: Int { get set }
    static var unitRawValue: Int { get set }
    static var notificationsEnabled: Bool { get set }
    static var inAppSoundsEnabled: Bool { get set }
    static var hapticFeedbackEnabled: Bool { get set }
    static var appleHealthIntegrationEnabled: Bool { get set }
}

class HydrateSettings: NSObject, SettingsConfigurable {
    
    static var targetDailyIntake: Int {
        get { HydrateSettings.value(for: #keyPath(targetDailyIntake)) ?? 96 } // 96 is the default value if never set before
        set { HydrateSettings.updateDefaults(for: #keyPath(targetDailyIntake), value: newValue) }
    }
    
    static var unitRawValue: Int {
        get { HydrateSettings.value(for: #keyPath(unitRawValue)) ?? 1 }
        set { HydrateSettings.updateDefaults(for: #keyPath(unitRawValue), value: newValue) }
    }
    
    static var unit: Unit {
        get { Unit(rawValue: HydrateSettings.unitRawValue)! }
        set { unitRawValue = newValue.rawValue }
    }
    
    static var notificationsEnabled: Bool {
        get { HydrateSettings.value(for: #keyPath(notificationsEnabled)) ?? false }
        set { HydrateSettings.updateDefaults(for: #keyPath(notificationsEnabled), value: newValue) }
    }
    
    static var inAppSoundsEnabled: Bool {
        get { HydrateSettings.value(for: #keyPath(inAppSoundsEnabled)) ?? false }
        set { HydrateSettings.updateDefaults(for: #keyPath(inAppSoundsEnabled), value: newValue) }
    }
    
    static var appleHealthIntegrationEnabled: Bool {
        get { HydrateSettings.value(for: #keyPath(appleHealthIntegrationEnabled)) ?? false }
        set { HydrateSettings.updateDefaults(for: #keyPath(appleHealthIntegrationEnabled), value: newValue) }
    }
    
    static var hapticFeedbackEnabled: Bool {
        get { HydrateSettings.value(for: #keyPath(hapticFeedbackEnabled)) ?? false }
        set { HydrateSettings.updateDefaults(for: #keyPath(hapticFeedbackEnabled), value: newValue) }
    }
    
    // MARK: - Private Methods
    
    private static func updateDefaults(for key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        sendSettingsChangedNotification()
    }
    
    private static func value<T>(for key: String) -> T? {
        UserDefaults.standard.value(forKey: key) as? T
    }
    
    private static func sendSettingsChangedNotification() {
        let notification = Notification(name: .settingsChanged)
        NotificationQueue.default.enqueue(notification, postingStyle: .asap, coalesceMask: .onName, forModes: [.common])
    }
}

enum Unit: Int, CaseIterable, CustomStringConvertible {
    case milliliters
    case fluidOunces
    case cups
    
    var description: String {
        switch self {
        case .milliliters: return "milliliters"
        case .fluidOunces: return "fluid ounces"
        case .cups: return "cups"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .milliliters: return "mL"
        case .fluidOunces: return "oz."
        case .cups: return "cups"
        }
    }
    
    var conversionFactor: Double {
        switch self {
        case .milliliters: return 1.0
        case .fluidOunces: return 29.5735
        case .cups: return 240
        }
    }
}

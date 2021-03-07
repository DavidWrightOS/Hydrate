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
    static let notificationsEnabledSettingChanged = Notification.Name("notificationsEnabledSettingChanged")
    static let notificationSettingsChanged = Notification.Name("NotificationSettingsChanged")
}

@objc protocol SettingsTracking {
    @objc func settingsDataChanged()
    @objc func notificationSettingsDataChanged()
    @objc func notificationsEnabledSettingDataChanged()
}

extension SettingsTracking {
    func registerForSettingsChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(settingsDataChanged),
                                               name: .settingsChanged,
                                               object: nil)
    }
    
    func registerForNotificationSettingsChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationSettingsDataChanged),
                                               name: .notificationSettingsChanged,
                                               object: nil)
    }
    
    func registerForNotificationsEnabledSettingChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationsEnabledSettingDataChanged),
                                               name: .notificationsEnabledSettingChanged,
                                               object: nil)
    }
}

@objc protocol SettingsConfigurable {
    static var targetDailyIntake: Double { get set }
    static var unitRawValue: Int { get set }
    static var notificationsEnabled: Bool { get set }
    static var wakeUpTime: Int { get set } // minutes from 12:00 AM
    static var bedTime: Int { get set } // minutes from 12:00 AM
    static var notificationsPerDay: Int { get set }
    static var appleHealthIntegrationEnabled: Bool { get set }
}

class HydrateSettings: NSObject, SettingsConfigurable {
    
    static var targetDailyIntake: Double {
        get {
            let targetInMilliliters = HydrateSettings.value(for: #keyPath(targetDailyIntake)) ?? 2366.0
            let targetInCurrentUnit = targetInMilliliters * unit.conversionFactor
            return targetInCurrentUnit
        }
        set {
            let newTarget = newValue / unit.conversionFactor
            guard newTarget != targetDailyIntake else { return }
            HydrateSettings.updateDefaults(for: #keyPath(targetDailyIntake), value: newTarget)
        }
    }
    
    static var unitRawValue: Int {
        get { HydrateSettings.value(for: #keyPath(unitRawValue)) ?? 1 }
        set {
            guard newValue != unitRawValue else { return }
            HydrateSettings.updateDefaults(for: #keyPath(unitRawValue), value: newValue)
        }
    }
    
    static var unit: Unit {
        get { Unit(rawValue: HydrateSettings.unitRawValue)! }
        set {
            guard newValue != unit else { return }
            unitRawValue = newValue.rawValue
        }
    }
    
    static var notificationsEnabled: Bool {
        get { HydrateSettings.value(for: #keyPath(notificationsEnabled)) ?? false }
        set {
            guard newValue != notificationsEnabled else { return }
            HydrateSettings.updateDefaults(for: #keyPath(notificationsEnabled), value: newValue)
        }
    }
    
    static var wakeUpTime: Int {
        get { HydrateSettings.value(for: #keyPath(wakeUpTime)) ?? 540 } // default is 540 minutes (9:00 AM)
        set {
            guard newValue != wakeUpTime else { return }
            HydrateSettings.updateDefaults(for: #keyPath(wakeUpTime), value: newValue)
        }
    }
    
    static var bedTime: Int {
        get { HydrateSettings.value(for: #keyPath(bedTime)) ?? 1320 } // default is 1320 minutes (10:00 PM)
        set {
            guard newValue != bedTime else { return }
            HydrateSettings.updateDefaults(for: #keyPath(bedTime), value: newValue)
        }
    }
    
    static var notificationsPerDay: Int {
        get { HydrateSettings.value(for: #keyPath(notificationsPerDay)) ?? 8 }
        set {
            guard newValue != notificationsPerDay else { return }
            HydrateSettings.updateDefaults(for: #keyPath(notificationsPerDay), value: newValue)
        }
    }
    
    static var appleHealthIntegrationEnabled: Bool {
        get { HydrateSettings.value(for: #keyPath(appleHealthIntegrationEnabled)) ?? false }
        set {
            guard newValue != appleHealthIntegrationEnabled else { return }
            HydrateSettings.updateDefaults(for: #keyPath(appleHealthIntegrationEnabled), value: newValue)
        }
    }
    
    // MARK: - Private Methods
    
    private static func updateDefaults(for key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        
        switch key {
        case #keyPath(notificationsEnabled):
            sendNotificationsEnabledSettingChangedNotification()
        case #keyPath(notificationsPerDay),
             #keyPath(wakeUpTime),
             #keyPath(bedTime):
            sendNotificationSettingsChangedNotification()
        default:
            sendSettingsChangedNotification()
        }
    }
    
    private static func value<T>(for key: String) -> T? {
        UserDefaults.standard.value(forKey: key) as? T
    }
    
    private static func sendSettingsChangedNotification() {
        let notification = Notification(name: .settingsChanged)
        NotificationQueue.default.enqueue(notification, postingStyle: .asap, coalesceMask: .onName, forModes: [.common])
    }
    
    private static func sendNotificationsEnabledSettingChangedNotification() {
        let notification = Notification(name: .notificationsEnabledSettingChanged)
        NotificationQueue.default.enqueue(notification, postingStyle: .asap, coalesceMask: .onName, forModes: [.common])
    }
    
    private static func sendNotificationSettingsChangedNotification() {
        let notification = Notification(name: .notificationSettingsChanged)
        NotificationQueue.default.enqueue(notification, postingStyle: .asap, coalesceMask: .onName, forModes: [.common])
    }
    
    }
}

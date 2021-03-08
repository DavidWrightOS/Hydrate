//
//  HydrateSettings.swift
//  Hydrate
//
//  Created by David Wright on 10/14/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

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

extension UserDefaults {
    enum Key: String {
        case targetDailyIntake
        case unitRawValue
        case notificationsEnabled
        case wakeUpTime
        case bedTime
        case notificationsPerDay
        case appleHealthIntegrationEnabled
    }
}

class HydrateSettings {
    
    static var targetDailyIntake: Double {
        get {
            let targetInMilliliters = HydrateSettings.value(for: .targetDailyIntake) ?? 2366.0
            let targetInCurrentUnit = targetInMilliliters * unit.conversionFactor
            return targetInCurrentUnit
        }
        set {
            let newTarget = newValue / unit.conversionFactor
            guard newTarget != targetDailyIntake else { return }
            HydrateSettings.updateDefaults(for: .targetDailyIntake, value: newTarget)
        }
    }
    
    static var unit: Unit {
        get {
            let unitRawValue = HydrateSettings.value(for: .unitRawValue) ?? 1
            return Unit(rawValue: unitRawValue)! }
        set {
            guard newValue != unit else { return }
            HydrateSettings.updateDefaults(for: .unitRawValue, value: newValue.rawValue)
        }
    }
    
    static var notificationsEnabled: Bool {
        get { HydrateSettings.value(for: .notificationsEnabled) ?? false }
        set {
            guard newValue != notificationsEnabled else { return }
            HydrateSettings.updateDefaults(for: .notificationsEnabled, value: newValue)
        }
    }
    
    /// time of day measured in minutes from 12:00 AM
    static var wakeUpTime: Int {
        get { HydrateSettings.value(for: .wakeUpTime) ?? 540 } // default is 540 minutes (9:00 AM)
        set {
            guard newValue != wakeUpTime else { return }
            HydrateSettings.updateDefaults(for: .wakeUpTime, value: newValue)
        }
    }
    
    /// time of day measured in minutes from 12:00 AM
    static var bedTime: Int {
        get { HydrateSettings.value(for: .bedTime) ?? 1320 } // default is 1320 minutes (10:00 PM)
        set {
            guard newValue != bedTime else { return }
            HydrateSettings.updateDefaults(for: .bedTime, value: newValue)
        }
    }
    
    static var notificationsPerDay: Int {
        get { HydrateSettings.value(for: .notificationsPerDay) ?? 8 }
        set {
            guard newValue != notificationsPerDay else { return }
            HydrateSettings.updateDefaults(for: .notificationsPerDay, value: newValue)
        }
    }
    
    static var appleHealthIntegrationEnabled: Bool {
        get { HydrateSettings.value(for: .appleHealthIntegrationEnabled) ?? false }
        set {
            guard newValue != appleHealthIntegrationEnabled else { return }
            HydrateSettings.updateDefaults(for: .appleHealthIntegrationEnabled, value: newValue)
        }
    }
    
    // MARK: - Private Methods
    
    private static func updateDefaults(for key: UserDefaults.Key, value: Any) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        sendNotification(for: key)
    }
    
    private static func value<T>(for key: UserDefaults.Key) -> T? {
        UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
}


// MARK: - Notifications

extension Notification.Name {
    static let settingsChanged = Notification.Name("SettingsChanged")
    static let notificationsEnabledSettingChanged = Notification.Name("notificationsEnabledSettingChanged")
    static let notificationSettingsChanged = Notification.Name("NotificationSettingsChanged")
}

extension HydrateSettings {
    
    private static func sendNotification(for key: UserDefaults.Key) {
        switch key {
        case .notificationsEnabled:
            sendNotificationsEnabledSettingChangedNotification()
        case .notificationsPerDay, .wakeUpTime, .bedTime:
            sendNotificationSettingsChangedNotification()
        default:
            sendSettingsChangedNotification()
        }
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

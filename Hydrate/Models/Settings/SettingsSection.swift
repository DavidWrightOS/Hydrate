//
//  SettingsSection.swift
//  Hydrate
//
//  Created by David Wright on 9/28/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

protocol SettingOption: CustomStringConvertible {
    var settingsCellType: SettingsCellType { get }
    func updateValue(to value: Any)
}

extension SettingOption {
    func updateValue(to value: Any) {}
}

enum SettingsCellType {
    case disclosureIndicator
    case onOffSwitch(Bool)
    case stepperControl(Double)
    case timePicker(Date)
    case detailLabel(String)
}

// MARK: - Settings TableView Sections

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case general
    case notifications
    case appSettings
    case about
    
    var description: String {
        switch self {
        case .general: return "General"
        case .notifications: return "Notifications"
        case .appSettings: return "App Settings"
        case .about: return "About"
        }
    }
    
    var headerText: String? {
        switch self {
        case .general: return nil
        default: return description
        }
    }
    
    var footerText: String? {
        switch self {
        case .notifications: return "Set a time to show a notification when there are all-day reminders (with no specified time)."
        default: return nil
        }
    }
    
    var settingOptions: [SettingOption] {
        switch self {
        case .general: return GeneralSettings.allCases
        case .notifications: return HydrateSettings.notificationsEnabled ? NotificationSettingsExpanded.allCases : NotificationSettings.allCases
        case .appSettings: return AppSettings.allCases
        case .about: return AboutSettings.allCases
        }
    }
}

// MARK: - Settings TableView Rows
// Each enum defined below is its own section, and the cases are the rows in that section

enum GeneralSettings: Int, CaseIterable, SettingOption {
    case targetDailyIntake
    case unit
    
    var settingsCellType: SettingsCellType {
        switch self {
        case .targetDailyIntake: return .detailLabel(String(HydrateSettings.targetDailyIntake))
        case .unit: return .detailLabel(HydrateSettings.unit.abbreviation)
        }
    }
    
    func updateValue(to value: Any) {
        switch self {
        case .targetDailyIntake: HydrateSettings.targetDailyIntake = value as! Int
        case .unit: HydrateSettings.unit = value as! Unit
        }
    }
    
    var description: String {
        switch self {
        case .targetDailyIntake: return "Target Daily Intake"
        case .unit: return "Unit"
        }
    }
}

enum NotificationSettings: Int, CaseIterable, SettingOption {
    case receiveNotifications
    
    var settingsCellType: SettingsCellType {
        switch self {
        case .receiveNotifications: return .onOffSwitch(HydrateSettings.notificationsEnabled)
        }
    }
    
    func updateValue(to value: Any) {
        switch self {
        case .receiveNotifications: HydrateSettings.notificationsEnabled = value as! Bool
        }
    }
    
    var description: String {
        switch self {
        case .receiveNotifications: return "Receive Notifications"
        }
    }
}

enum AppSettings: Int, CaseIterable, SettingOption {
    case inAppSounds
    case hapticFeedback
    case addToHealthApp
    
    var settingsCellType: SettingsCellType {
        switch self {
        case .inAppSounds: return .onOffSwitch(HydrateSettings.inAppSoundsEnabled)
        case .hapticFeedback: return .onOffSwitch(HydrateSettings.hapticFeedbackEnabled)
        case .addToHealthApp: return .onOffSwitch(HydrateSettings.appleHealthIntegrationEnabled)
        }
    }
    
    func updateValue(to value: Any) {
        switch self {
        case .inAppSounds: HydrateSettings.inAppSoundsEnabled = value as! Bool
        case .hapticFeedback: HydrateSettings.hapticFeedbackEnabled = value as! Bool
        case .addToHealthApp: HydrateSettings.appleHealthIntegrationEnabled = value as! Bool
        }
    }
    
    var description: String {
        switch self {
        case .inAppSounds: return "In App Sounds"
        case .hapticFeedback: return "Haptic Feedback"
        case .addToHealthApp: return "Add to Health App"
        }
    }
}

enum AboutSettings: Int, CaseIterable, SettingOption {
    case reportIssue
    case rateApp
    case aboutUs
    
    var settingsCellType: SettingsCellType { return .disclosureIndicator }
            
    var description: String {
        switch self {
        case .reportIssue: return "Report an Issue"
        case .rateApp: return "Rate the App"
        case .aboutUs: return "About Us"
        }
    }
}

enum NotificationSettingsExpanded: Int, CaseIterable, SettingOption {
    case receiveNotifications
    case notificationsPerDay
    case wakeUpTime
    case bedTime
    
    var settingsCellType: SettingsCellType {
        switch self {
        case .receiveNotifications: return .onOffSwitch(HydrateSettings.notificationsEnabled)
        case .notificationsPerDay: return .stepperControl(Double(HydrateSettings.notificationsPerDay))
        case .wakeUpTime: return .timePicker(date(totalMinutes: HydrateSettings.wakeUpTime))
        case .bedTime: return .timePicker(date(totalMinutes: HydrateSettings.bedTime))
        }
    }
    
    private func date(totalMinutes: Int) -> Date {
        let hours = totalMinutes / 60
        let minutes = totalMinutes - hours * 60
        return Calendar.current.date(from: DateComponents(hour: hours, minute: minutes))!
    }
    
    func updateValue(to value: Any) {
        switch self {
        case .receiveNotifications: HydrateSettings.notificationsEnabled = value as! Bool
        case .notificationsPerDay: HydrateSettings.notificationsPerDay = value as! Int
        case .wakeUpTime: HydrateSettings.wakeUpTime = value as! Int
        case .bedTime: HydrateSettings.bedTime = value as! Int
        }
    }
    
    var description: String {
        switch self {
        case .receiveNotifications: return "Receive Notifications"
        case .notificationsPerDay: return "Daily Notifications"
        case .wakeUpTime: return "Wake Up Time"
        case .bedTime: return "Bed Time"
        }
    }
}

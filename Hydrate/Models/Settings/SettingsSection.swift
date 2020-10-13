//
//  SettingsSection.swift
//  Hydrate
//
//  Created by David Wright on 9/28/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

protocol SettingOption: CustomStringConvertible {
    var settingsCellType: SettingsCellType { get }
}

enum SettingsCellType: Int, CaseIterable {
    case disclosureIndicator
    case onOffSwitch
    case dynamicText
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
        case .notifications: return "Notifications"
        case .appSettings: return "App Settings"
        case .about: return "About"
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
        case .notifications: return NotificationSettings.allCases
        case .appSettings: return AppSettings.allCases
        case .about: return AboutSettings.allCases
        }
    }
}

// MARK: - Settings TableView Rows

enum GeneralSettings: Int, CaseIterable, SettingOption {
    case targetDailyIntake
    case unit
    
    var settingsCellType: SettingsCellType {
        switch self {
        case .targetDailyIntake: return .dynamicText
        case .unit: return .dynamicText
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
    
    var settingsCellType: SettingsCellType { return .onOffSwitch }
    
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
    
    var settingsCellType: SettingsCellType { return .onOffSwitch }
    
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

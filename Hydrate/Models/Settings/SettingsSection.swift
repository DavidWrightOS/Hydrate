//
//  SettingsSection.swift
//  Hydrate
//
//  Created by David Wright on 9/28/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

protocol SettingOption: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

// MARK: - Settings TableView Sections

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case notifications
    case appSettings
    case about
    
    var description: String {
        switch self {
        case .notifications: return "Notifications"
        case .appSettings: return "App Settings"
        case .about: return "About"
        }
    }
    
    var headerText: String? { description }
    
    var footerText: String? {
        switch self {
        case .notifications: return "Set a time to show a notification when there are all-day reminders (with no specified time)."
        default: return nil
        }
    }
}

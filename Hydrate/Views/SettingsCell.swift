//
//  SettingsCell.swift
//  Hydrate
//
//  Created by David Wright on 9/28/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - Properties
    
    var setting: SettingOption? {
        didSet {
            guard let setting = setting else { return }
            textLabel?.text = setting.description
            detailTextLabel?.text = setting.description
            switch setting.settingsCellType {
            case .onOffSwitch:
                self.accessoryType = .none
            default:
                addDisclosureIndicator()
            }
            
            switchControl.isHidden = setting.settingsCellType != .onOffSwitch
            detailTextLabel?.text = setting.settingsCellType == .dynamicText ? "Dynamic Text" : nil
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = .actionColor
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return switchControl
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .ravenClawBlue90
        textLabel?.textColor = .undeadWhite
        detailTextLabel?.textColor = UIColor.undeadWhite.withAlphaComponent(0.5)
        
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleSwitchAction(sender: UISwitch) {
        if sender.isOn {
            print("Debug: \(setting?.description ?? "?") turned ON..")
        } else {
            print("Debug: \(setting?.description ?? "?") turned OFF..")
        }
    }
}

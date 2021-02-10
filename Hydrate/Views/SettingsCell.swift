//
//  SettingsCell.swift
//  Hydrate
//
//  Created by David Wright on 9/28/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    static let reuseIdentifier = "SettingsCell"
    
    // MARK: - Properties
    
    var setting: SettingOption? {
        didSet {
            guard let setting = setting else { return }
            
            textLabel?.text = setting.description
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .ravenClawBlue90
            selectedBackgroundView = backgroundView
            
            switch setting.settingsCellType {
            case .onOffSwitch(let switchState):
                selectionStyle = .none
                self.accessoryType = .none
                switchControl.isOn = switchState
                switchControl.isHidden = false
                detailTextLabel?.text = nil
            case .detailLabel(let detailString):
                selectionStyle = .default
                addDisclosureIndicator()
                switchControl.isHidden = true
                detailTextLabel?.text = detailString
            default:
                selectionStyle = .none
                addDisclosureIndicator()
                switchControl.isHidden = true
                detailTextLabel?.text = nil
            }
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
        setting?.updateValue(to: sender.isOn)
    }
}

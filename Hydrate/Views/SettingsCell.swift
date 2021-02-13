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
            configure()
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
    
    lazy var stepperControl: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 10
        
        let decrementImageTinted = stepper.decrementImage(for: .normal)?
            .withTintColor(.undeadWhite, renderingMode: .alwaysOriginal)
        stepper.setDecrementImage(decrementImageTinted, for: .normal)

        let incrementImageTinted = stepper.incrementImage(for: .normal)?
            .withTintColor(.undeadWhite, renderingMode: .alwaysOriginal)
        stepper.setIncrementImage(incrementImageTinted, for: .normal)
        
        stepper.layer.backgroundColor = UIColor.ravenClawBlue80.cgColor
        stepper.layer.cornerRadius = 8
        stepper.layer.cornerCurve = .continuous
        
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.addTarget(self, action: #selector(handleStepperAction), for: .valueChanged)
        return stepper
    }()
    
    lazy var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .compact
        } else {
            timePicker.preferredDatePickerStyle = .wheels
        }
        
        timePicker.tintColor = .undeadWhite
        timePicker.layer.backgroundColor = UIColor.ravenClawBlue80.cgColor
        timePicker.layer.cornerRadius = 8
        timePicker.layer.cornerCurve = .continuous
        
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.addTarget(self, action: #selector(handleTimePickerChanged), for: .editingDidEnd)
        return timePicker
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
        
        addSubview(stepperControl)
        stepperControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stepperControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
        addSubview(timePicker)
        timePicker.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        timePicker.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleSwitchAction(sender: UISwitch) {
        setting?.updateValue(to: sender.isOn)
    }
    
    @objc func handleStepperAction(sender: UIStepper) {
        let stepperValue = Int(sender.value)
        setting?.updateValue(to: stepperValue)
        
        if let text = setting?.description {
            textLabel?.text = text + ": \(stepperValue)"
        } else {
            textLabel?.text = "\(stepperValue)"
        }
    }
    
    @objc func handleTimePickerChanged(sender: UIDatePicker) {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: sender.date)
        let hours = dateComponents.hour ?? 0
        let minutes = dateComponents.minute ?? 0
        let totalMinutes = hours * 60 + minutes
        setting?.updateValue(to: totalMinutes)
    }
}

// MARK: - Configure Cell

extension SettingsCell {
    
    private func configure() {
        guard let setting = setting else { return }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .ravenClawBlue90
        selectedBackgroundView = backgroundView
        
        textLabel?.text = setting.description
        selectionStyle = .none
        detailTextLabel?.text = nil
        accessoryType = .none
        
        switchControl.isHidden = true
        stepperControl.isHidden = true
        timePicker.isHidden = true
        
        switch setting.settingsCellType {
        case .onOffSwitch(let switchState):
            switchControl.isHidden = false
            switchControl.isOn = switchState
        case .stepperControl(let stepperValue):
            stepperControl.isHidden = false
            stepperControl.value = stepperValue
        case .timePicker(let date):
            timePicker.isHidden = false
            timePicker.date = date
        case .detailLabel(let detailString):
            selectionStyle = .default
            addDisclosureIndicator()
            detailTextLabel?.text = detailString
        default:
            addDisclosureIndicator()
        }
    }
}


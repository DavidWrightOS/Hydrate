//
//  SettingsViewController.swift
//  Hydrate
//
//  Created by David Wright on 9/26/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var isNotificationSectionExpanded: Bool {
        tableView.numberOfRows(inSection: SettingsSection.notifications.rawValue) > NotificationSettings.allCases.count
    }
    
    private lazy var expandedNotificationsSectionIndexPaths: [IndexPath] = {
        var indexPaths = [IndexPath]()
        let sectionIndex = SettingsSection.notifications.rawValue
        var numberOfRowsBeforeExpanding = NotificationSettings.allCases.count
        
        for row in NotificationSettingsExpanded.allCases.dropFirst(numberOfRowsBeforeExpanding) {
            let rowIndex = row.rawValue
            let indexPath = IndexPath(row: row.rawValue, section: sectionIndex)
            indexPaths.append(indexPath)
        }
        return indexPaths
    }()
    
    // MARK: - UI Components
    
    private let navigationBar: UINavigationBar = {
        let navigationItem = UINavigationItem(title: "Settings")
        let navigationBar = UINavigationBar()
        navigationBar.prefersLargeTitles = true
        navigationBar.setItems([navigationItem], animated: false)
        navigationBar.barTintColor = .ravenClawBlue
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.undeadWhite]
        navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.undeadWhite]
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .actionColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        return navigationBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseIdentifier)
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = .ravenClawBlue
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsEnabledSettingChanged),
                                               name: .notificationsEnabledSettingChanged,
                                               object: nil)
        
        view.backgroundColor = .ravenClawBlue
        configureNavigationBar()
        configureTableView()
    }

    // MARK: - Helpers
    
    private func configureNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.anchor(top: view.topAnchor,
                             leading: view.leadingAnchor,
                             bottom: nil,
                             trailing: view.trailingAnchor)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
                
        view.addSubview(tableView)
        tableView.anchor(top: navigationBar.bottomAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
    }
    
    private func presentTargetIntakeSelectionView(for indexPath: IndexPath) {
        let title = "Target Intake"
        let message = "Enter your target daily water intake."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = .actionColorHighContrast
        
        let currentValue = HydrateSettings.targetDailyIntake
        
        alertController.addTextField { textField in
            textField.placeholder = title
            textField.text = String(currentValue)
            textField.font = .systemFont(ofSize: 16)
            textField.textColor = .actionColorHighContrast
            
            let unitLabel = UILabel()
            unitLabel.font = .systemFont(ofSize: 16)
            unitLabel.textColor = .placeholderText
            unitLabel.text = HydrateSettings.unit.abbreviation
            textField.addSubview(unitLabel)
            textField.rightView = unitLabel
            textField.rightViewMode = .always
            textField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.tableView.deselectRow(at: indexPath, animated: false)
        }
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] _ in
            guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
            
            if let string = textField.text, let newValue = Int(string), newValue != currentValue {
                HydrateSettings.targetDailyIntake = newValue
                self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = string
                self?.tableView.deselectRow(at: indexPath, animated: false)
            }
            
        }
        
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }
    
    private func presentUnitSelectionView(for indexPath: IndexPath) {
        let title = "Select Unit"
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = .actionColorHighContrast
        
        let currentUnit = HydrateSettings.unit
        
        for unit in Unit.allCases {
            let actionTitle = unit.abbreviation != unit.description ?
                "\(unit.abbreviation) (\(unit.description))" : "\(unit.abbreviation)"
            
            let action = UIAlertAction(title: actionTitle, style: .default) { [weak self] (action) in
                if unit != currentUnit {
                    HydrateSettings.unit = unit
                    self?.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = unit.abbreviation
                    self?.tableView.deselectRow(at: indexPath, animated: false)
                }
            }
            
            let shouldShowCheckmark = unit == currentUnit
            action.setValue(shouldShowCheckmark, forKey: "checked")
            alertController.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        alertController.addAction(cancel)
        
        present(alertController, animated: true)
    }
    
    private func handleReportIssue() {
        if let url = URL(string: "https://github.com/DavidWrightOS/Hydrate/issues") {
            UIApplication.shared.open(url) { success in
                guard !success else { return }
                self.presentSimpleAlert(title: "Sorry 😕", message: "The link is currently broken. Please try back later.")
            }
        } else {
            presentSimpleAlert(title: "Sorry 😕", message: "The link is currently broken. Please try back later.")
        }
    }
    
    private func handleRateApp() {
        print("DEBUG: Handle Rate App..")
    }
    
    private func handleAboutUs() {
        print("DEBUG: Handle About Us..")
    }
    
    // MARK: - Selectors
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func notificationsEnabledSettingChanged() {
        let notificationsEnabled = HydrateSettings.notificationsEnabled
        
        guard notificationsEnabled != isNotificationSectionExpanded else { return }
        
        if notificationsEnabled {
            let notificationManager = LocalNotificationManager()
            notificationManager.requestAuthorization() { [weak self] granted in
                if granted {
                    self?.showNotificationsSectionDetails()
                } else {
                    self?.presentNotificationPermissionsAlert()
                }
            }
        } else {
            hideNotificationsSectionDetails()
        }
    }
    
    private func showNotificationsSectionDetails() {
        guard !isNotificationSectionExpanded else { return }

        tableView.beginUpdates()
        tableView.insertRows(at: expandedNotificationsSectionIndexPaths, with: .automatic)
        tableView.endUpdates()
    }
    
    private func hideNotificationsSectionDetails() {
        guard isNotificationSectionExpanded else { return }
        
        tableView.beginUpdates()
        tableView.deleteRows(at: expandedNotificationsSectionIndexPaths, with: .automatic)
        tableView.endUpdates()
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .ravenClawBlue
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.undeadWhite.withAlphaComponent(0.5)
        if let text = SettingsSection(rawValue: section)?.headerText {
            label.text = text.uppercased()
        }
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .ravenClawBlue
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = UIColor.undeadWhite.withAlphaComponent(0.5)
        label.text = SettingsSection(rawValue: section)?.footerText
        
        view.addSubview(label)
        label.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                       bottom: view.bottomAnchor, trailing: view.trailingAnchor,
                       padding: UIEdgeInsets(top: 4, left: 16, bottom: 16, right: 16))
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section),
              indexPath.row < section.settingOptions.count else { return }
                
        switch section {
        case .general:
            if let setting = section.settingOptions[indexPath.row] as? GeneralSettings {
                switch setting {
                case .targetDailyIntake: presentTargetIntakeSelectionView(for: indexPath)
                case .unit: presentUnitSelectionView(for: indexPath)
                }
            }
        case .about:
            if let setting = section.settingOptions[indexPath.row] as? AboutSettings {
                switch setting {
                case .reportIssue: handleReportIssue()
                case .rateApp: handleRateApp()
                case .aboutUs: handleAboutUs()
                }
            }
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        return section.settingOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableSettingsCell(in: tableView, indexPath: indexPath)
        guard let section = SettingsSection(rawValue: indexPath.section),
              indexPath.row < section.settingOptions.count else { return UITableViewCell() }
        
        cell.setting = section.settingOptions[indexPath.row]
        
        return cell
    }
    
    func dequeueReusableSettingsCell(in tableView: UITableView, indexPath: IndexPath) -> SettingsCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseIdentifier, for: indexPath) as? SettingsCell else {
            fatalError("Failed to dequeue a SettingsCell.")
        }
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none
        cell.accessoryView = .none
        return cell
    }
}

// MARK: - Local Notifications Permission

extension SettingsViewController {
    
    func presentNotificationPermissionsAlert() {
        
        let title = "Notifications are disabled"
        let message = "Please turn on notifications in the Settings app to enable reminder notifications."
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { [weak self] _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) { _ in
                let sectionIndex = SettingsSection.notifications.rawValue
                let rowIndex = NotificationSettings.receiveNotifications.rawValue
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                
                if let cell = self?.tableView.cellForRow(at: indexPath) as? SettingsCell {
                    cell.switchControl.isOn = false
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [weak self] _ in
            let sectionIndex = SettingsSection.notifications.rawValue
            let rowIndex = NotificationSettings.receiveNotifications.rawValue
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            
            if let cell = self?.tableView.cellForRow(at: indexPath) as? SettingsCell {
                cell.switchControl.isOn = false
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        alertController.preferredAction = settingsAction
        alertController.view.tintColor = .actionColorHighContrast
        alertController.overrideUserInterfaceStyle = .dark
        
        let subview = (alertController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.layer.cornerRadius = 1
        subview.backgroundColor = .ravenClawBlue
        
        present(alertController, animated: true, completion: nil)
    }
}

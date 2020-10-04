//
//  SettingsViewController.swift
//  Hydrate
//
//  Created by David Wright on 9/26/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    
    fileprivate let navigationBar: UINavigationBar = {
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
    
    fileprivate let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = .ravenClawBlue
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ravenClawBlue
        configureNavigationBar()
        configureTableView()
    }

    // MARK: - Helpers
    
    fileprivate func configureNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.anchor(top: view.topAnchor,
                             leading: view.leadingAnchor,
                             bottom: nil,
                             trailing: view.trailingAnchor)
    }
    
    fileprivate func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
                
        view.addSubview(tableView)
        tableView.anchor(top: navigationBar.bottomAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor)
    }
    
    // MARK: - Selectors
    
    @objc fileprivate func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
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
        
        let row = section.settingOptions[indexPath.row]
        
        print("Debug: \(row.description) tapped..")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        guard let section = SettingsSection(rawValue: indexPath.section),
              indexPath.row < section.settingOptions.count else { return UITableViewCell() }
        
        cell.setting = section.settingOptions[indexPath.row]
        
        return cell
    }
}

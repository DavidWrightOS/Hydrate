//
//  DataViewController.swift
//  Hydrate
//
//  Created by David Wright on 9/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import SwiftUI

class DataViewController: UIViewController {
    
    var dailyLogController: DailyLogController
    
    // MARK: - UI Components
    
    fileprivate let navigationBar: UINavigationBar = {
        let navigationItem = UINavigationItem(title: "Water Intake History")
        let navigationBar = UINavigationBar()
        navigationBar.setItems([navigationItem], animated: false)
        navigationBar.barTintColor = .ravenClawBlue
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.undeadWhite]
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .actionColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        return navigationBar
    }()
    
    fileprivate lazy var chartView = ChartView(dailyLogController: dailyLogController)
    
    fileprivate let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .lightGray
        return containerView
    }()
    
    fileprivate lazy var tableViewNavigationController: UINavigationController = {
        let dailyLogTableVC = DailyLogTableViewController()
        dailyLogTableVC.delegate = self
        let navController = UINavigationController(rootViewController: dailyLogTableVC)
        navController.navigationBar.barTintColor = .ravenClawBlue
        navController.navigationBar.tintColor = .actionColor
        navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.undeadWhite]
        navController.navigationBar.isTranslucent = false
        return navController
    }()
    
    // MARK: - Lifecycle
    
    init(dailyLogController: DailyLogController) {
        self.dailyLogController = dailyLogController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupViews() {
        view.backgroundColor = .ravenClawBlue
        setupNavigationBar()
        setupChartView()
        setupTableViewNavigationController()
    }
    
    fileprivate func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                             bottom: nil, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupChartView() {
        let today = Date().startOfDay
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today)!
        chartView.dailyLogs = dailyLogController.fetchDailyLogs(startingOn: sevenDaysAgo, through: today)
        chartView.updateDailyLogs()
        
        let childView = UIHostingController(rootView: chartView)
        addChild(childView)
        childView.didMove(toParent: self)
        
        view.addSubview(childView.view)
        childView.view.anchor(top: navigationBar.bottomAnchor,
                              leading: view.leadingAnchor,
                              bottom: nil,
                              trailing: view.trailingAnchor,
                              size: CGSize(width: view.bounds.width, height: 220))
        
        view.addSubview(containerView)
        containerView.anchor(top: childView.view.bottomAnchor,
                             leading: view.leadingAnchor,
                             bottom: view.bottomAnchor,
                             trailing: view.trailingAnchor)
    }
    
    fileprivate func setupTableViewNavigationController() {
        addChild(tableViewNavigationController)
        containerView.addSubview(tableViewNavigationController.view)
        tableViewNavigationController.didMove(toParent: self)
        tableViewNavigationController.view.anchor(top: containerView.topAnchor,
                                                  leading: containerView.leadingAnchor,
                                                  bottom: containerView.bottomAnchor,
                                                  trailing: containerView.trailingAnchor)
    }
    
    @objc fileprivate func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func presentAddDataAlert(for date: Date = Date()) {
        let title = "New Intake"
        let message = "Enter the new intake details."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = .actionColorHighContrast
        
        // Intake Amount Textfield
        alertController.addTextField { textField in
            textField.placeholder = "Enter intake amount"
            textField.text = nil
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
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        
        let currentDate = Date()
        let currentTime = currentDate.startOfDay.distance(to: currentDate)
        datePicker.date = date.startOfDay.addingTimeInterval(currentTime)
        
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .compact
        } else {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        // Date and Time Textfield
        alertController.addTextField { textField in
            textField.addSubview(datePicker)
            datePicker.anchor(top: textField.topAnchor, leading: textField.leadingAnchor, bottom: textField.bottomAnchor, trailing: textField.trailingAnchor)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController, weak datePicker] _ in
            guard let self = self,
                  let alertController = alertController,
                  let datePickerDate = datePicker?.date,
                  let amountText = alertController.textFields?.first?.text,
                  let amount = Int(amountText) else { return }
            
            self.dailyLogController.add(intakeAmount: amount, for: datePickerDate)
            
            guard let navController = self.children.last as? UINavigationController else { return }
            
            if let dailyLogTableVC = navController.topViewController as? DailyLogTableViewController {
                dailyLogTableVC.setEditing(false, animated: true)
            } else if let entriesTableVC = navController.topViewController as? EntriesTableViewController {
                entriesTableVC.setEditing(false, animated: true)
            }
        }
        
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }
}

extension DataViewController: DailyLogTableViewControllerDelegate {
    func addDataButtonTapped() {
        let date = dailyLogController.dailyLog?.date ?? Date()
        presentAddDataAlert(for: date)
    }
    
    func addDataButtonTapped(for date: Date) {
        presentAddDataAlert(for: date)
    }
}

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
    
    private let unit = HydrateSettings.unit
    
    // MARK: - UI Components
    
    private let navigationBar: UINavigationBar = {
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
    
    private lazy var chartView: ChartView = {
        let chartView = ChartView()
        chartView.dataSource = self
        chartView.delegate = self
        chartView.barWidth = 20
        return chartView
    }()
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .lightGray
        return containerView
    }()
    
    private lazy var tableViewNavigationController: UINavigationController = {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadIntakeEntries),
                                               name: .intakeEntriesDidChangeNotificationName, object: nil)
        
        setupViews()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .ravenClawBlue
        setupNavigationBar()
        setupChartView()
        setupTableViewNavigationController()
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                             bottom: nil, trailing: view.trailingAnchor)
    }
    
    private func setupChartView() {
        
        chartView.reloadChart()
        
        view.addSubview(chartView)
        chartView.anchor(top: navigationBar.bottomAnchor,
                         leading: view.leadingAnchor,
                         bottom: nil,
                         trailing: view.trailingAnchor)
        chartView.heightAnchor.constraint(equalTo: chartView.widthAnchor, multiplier: 4/5).isActive = true
        
        view.addSubview(containerView)
        containerView.anchor(top: chartView.bottomAnchor,
                             leading: view.leadingAnchor,
                             bottom: view.bottomAnchor,
                             trailing: view.trailingAnchor)
    }
    
    private func setupTableViewNavigationController() {
        addChild(tableViewNavigationController)
        containerView.addSubview(tableViewNavigationController.view)
        tableViewNavigationController.didMove(toParent: self)
        tableViewNavigationController.view.anchor(top: containerView.topAnchor,
                                                  leading: containerView.leadingAnchor,
                                                  bottom: containerView.bottomAnchor,
                                                  trailing: containerView.trailingAnchor)
    }
    
    @objc private func loadIntakeEntries() {
        chartView.reloadChart()
    }
    
    @objc private func doneButtonTapped() {
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
                  let amount = Double(amountText) else { return }
            
            let normalizedAmount = amount / self.unit.conversionFactor
            self.dailyLogController.add(intakeAmount: normalizedAmount, for: datePickerDate)
            
            guard let navController = self.children.last as? UINavigationController else { return }
            
            if let dailyLogTableVC = navController.topViewController as? DailyLogTableViewController {
                dailyLogTableVC.setEditing(false, animated: true)
            } else if let entriesTableVC = navController.topViewController as? EntriesTableViewController {
                entriesTableVC.setEditing(false, animated: true)
            }
        }
        
        alertController.addAction(saveAction)
        alertController.preferredAction = saveAction
        present(alertController, animated: true)
    }
    
    // MARK: - Date Formatters
    
    lazy var monthDayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter
    }()
    
    lazy var monthDayYearDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }()
    
    lazy var dayYearDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d, yyyy"
        return dateFormatter
    }()
    
    lazy var dayOfWeekFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        return dateFormatter
    }()
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


// MARK: - ChartViewDataSource

extension DataViewController: ChartViewDataSource {
    var chartValues: [CGFloat] {
        dailyTotalsForWeek()
    }
}

// MARK: - ChartViewDelegate

extension DataViewController: ChartViewDelegate {
    var chartTitle: String? {
        "Last Seven Days"
    }
    
    var chartSubtitle: String? {
        weeklyDateRangeString()
    }
    
    var chartUnitTitle: String? {
        HydrateSettings.unit.abbreviationFull
    }
    
    var chartHorizontalAxisMarkers: [String]? {
        horizontalAxisMarkers()
    }
}


// MARK: - ChartView Helpers

extension DataViewController {
    
    /// Return an array of CGFloat values representing the daily water intake over the last week
    func dailyTotalsForWeek(lastDate: Date = Date()) -> [CGFloat] {
        let calendar = Calendar.current
        let today = Date().startOfDay
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        let dailyLogs = dailyLogController.fetchDailyLogs(startingOn: sevenDaysAgo, through: today)
        
        let lastSevenDailyLogs = Array(dailyLogs.suffix(7))
        
        var dayOfWeekLabels: [String] = []
        var totalsToChart: [Double] = []
        
        for dayOffset in -6...0 {
            let day = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            dayOfWeekLabels.append(dayOfWeekFormatter.string(from: day))
            
            let dailyLog = lastSevenDailyLogs.first(where: { $0.date == day })
            let total = (dailyLog?.totalIntake ?? 0) * unit.conversionFactor
            totalsToChart.append(total)
        }
        
        return totalsToChart.map { CGFloat($0) }
    }
    
    /// Return a string describing the date range of the chart for the last week. Example: "Jun 3 - Jun 10, 2020"
    func weeklyDateRangeString(lastDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let endOfWeekDate = lastDate
        let startOfWeekDate = calendar.date(byAdding: .day, value: -6, to: endOfWeekDate)!
        
        var startDateString = monthDayDateFormatter.string(from: startOfWeekDate)
        var endDateString = monthDayYearDateFormatter.string(from: endOfWeekDate)
        
        // If the start and end dates are in the same month.
        if calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: .month) {
            endDateString = dayYearDateFormatter.string(from: endOfWeekDate)
        }
        
        // If the start and end dates are in different years.
        if !calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: .year) {
            startDateString = monthDayYearDateFormatter.string(from: startOfWeekDate)
        }
        
        return String(format: "%@–%@", startDateString, endDateString)
    }
    
    /// Returns an array of horizontal axis markers based on the desired time frame, where the last axis marker corresponds to `lastDate`
    /// `useWeekdays` will use short day abbreviations (e.g. "Sun, "Mon", "Tue") instead.
    /// Defaults to showing the current day as the last axis label of the chart and going back one week.
    func horizontalAxisMarkers(lastDate: Date = Date(), useWeekdays: Bool = true) -> [String] {
        let calendar: Calendar = .current
        let weekdayTitles = calendar.shortWeekdaySymbols
        
        var titles: [String] = []
        
        if useWeekdays {
            titles = weekdayTitles
            
            let weekday = calendar.component(.weekday, from: lastDate)
            
            return Array(titles[weekday..<titles.count]) + Array(titles[0..<weekday])
            
        } else {
            let numberOfDaysInWeek = weekdayTitles.count
            let startDate = calendar.date(byAdding: DateComponents(day: -(numberOfDaysInWeek - 1)), to: lastDate)!
            
            var date = startDate
            
            while date <= lastDate {
                titles.append(monthDayDateFormatter.string(from: date))
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
            
            return titles
        }
    }
}

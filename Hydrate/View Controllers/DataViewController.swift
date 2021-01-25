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
    
    var dailyLogController: DailyLogController?
    
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
    
    fileprivate let chartView: UIView = {
        let chartView = UIView()
        chartView.backgroundColor = .ravenClawBlue
        return chartView
    }()
    
    fileprivate let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .lightGray
        return containerView
    }()
    
    fileprivate lazy var tableViewNavigationController: UINavigationController = {
        let dailyLogTableVC = DailyLogTableViewController()
        let navController = UINavigationController(rootViewController: dailyLogTableVC)
        navController.navigationBar.barTintColor = .ravenClawBlue
        navController.navigationBar.tintColor = .actionColor
        navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.undeadWhite]
        navController.navigationBar.isTranslucent = false
        return navController
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupViews() {
        view.backgroundColor = .ravenClawBlue
        setupNavigationBar()
        setupChartView()
        setupContainerView()
    }
    
    fileprivate func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                             bottom: nil, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupChartView() {
        view.addSubview(chartView)
        
        var chartsView = ChartView()
        let startOfLastSevenDays = Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfDay)!
        let dailyLogs = dailyLogController?.fetchDailyLogs() ?? []
        chartsView.dailyLogs = dailyLogs.filter { $0.date != nil && $0.date! >= startOfLastSevenDays }
        chartsView.updateDailyLogs()
        
        let childView = UIHostingController(rootView: chartsView)
        addChild(childView)
        childView.didMove(toParent: self)
        chartView.addSubview(childView.view)
        childView.view.anchor(top: chartView.topAnchor,
                              leading: chartView.leadingAnchor,
                              bottom: chartView.bottomAnchor,
                              trailing: chartView.trailingAnchor)
        
        chartView.anchor(top: navigationBar.bottomAnchor, leading: view.leadingAnchor,
                         bottom: nil, trailing: view.trailingAnchor,
                         size: CGSize(width: view.bounds.width, height: 220))
    }
    
    fileprivate func setupContainerView() {
        view.addSubview(containerView)
        containerView.anchor(top: chartView.bottomAnchor, leading: view.leadingAnchor,
                             bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        setupTableViewNavigationController()
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
}

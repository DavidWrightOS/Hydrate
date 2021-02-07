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
    
    fileprivate let chartViewContainer: UIView = {
        let chartView = UIView()
        chartView.backgroundColor = .ravenClawBlue
        return chartView
    }()
    
    fileprivate lazy var chartView = ChartView(dailyLogController: dailyLogController)
    
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
        setupContainerView()
    }
    
    fileprivate func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                             bottom: nil, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupChartView() {
        view.addSubview(chartViewContainer)
        
        let today = Date().startOfDay
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: today)!
        chartView.dailyLogs = dailyLogController.fetchDailyLogs(startingOn: sevenDaysAgo, through: today)
        chartView.updateDailyLogs()
        
        let childView = UIHostingController(rootView: chartView)
        addChild(childView)
        childView.didMove(toParent: self)
        chartViewContainer.addSubview(childView.view)
        childView.view.anchor(top: chartViewContainer.topAnchor,
                              leading: chartViewContainer.leadingAnchor,
                              bottom: chartViewContainer.bottomAnchor,
                              trailing: chartViewContainer.trailingAnchor)
        
        chartViewContainer.anchor(top: navigationBar.bottomAnchor, leading: view.leadingAnchor,
                         bottom: nil, trailing: view.trailingAnchor,
                         size: CGSize(width: view.bounds.width, height: 220))
    }
    
    fileprivate func setupContainerView() {
        view.addSubview(containerView)
        containerView.anchor(top: chartViewContainer.bottomAnchor, leading: view.leadingAnchor,
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

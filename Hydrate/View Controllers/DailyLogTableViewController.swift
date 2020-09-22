//
//  DailyLogTableViewController.swift
//  Hydrate
//
//  Created by David Wright on 9/20/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import CoreData

class DailyLogTableViewController: UITableViewController {

    // MARK: - Properties
    lazy var  coreDataStack = CoreDataStack.shared
    
    lazy var fetchedResultsController: NSFetchedResultsController<IntakeEntry> = {
        let fetchRequest: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(IntakeEntry.timestamp), ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.mainContext,
            sectionNameKeyPath: nil,
            cacheName: "hydrate")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
                
        configureTableView()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    // MARK: - Private Properties
    
    fileprivate static var dailyLogCell: UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "intakeEntryCell")
        cell.backgroundColor = .ravenClawBlue90
        cell.tintColor = .sicklySmurfBlue
        cell.textLabel?.textColor = .undeadWhite
        cell.detailTextLabel?.textColor = .undeadWhite
        cell.addDisclosureIndicator()
        cell.selectionStyle = .none
        return cell
    }
    
    fileprivate lazy var addDataButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Add Data", style: .plain, target: self, action: #selector(addDataButtonTapped))
    }()
    
    fileprivate var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    // MARK: - Private Methods
    
    fileprivate func configureTableView() {
        title = "Daily Logs"
        tableView = UITableView(frame: self.tableView.frame, style: .insetGrouped)
        tableView.backgroundColor = .ravenClawBlue
        tableView.separatorColor = .ravenClawBlue
    }
    
    func updateViews() {
        guard isViewLoaded else { return }
        setEditing(false, animated: true)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "dailyLogCell")
        if cell == nil {
            cell = DailyLogTableViewController.dailyLogCell
        }
        
        cell.textLabel?.text = dateFormatter.string(from: Date())
        cell.detailTextLabel?.text = "0 oz."
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            self.navigationItem.leftBarButtonItem = self.addDataButton
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc fileprivate func addDataButtonTapped() {
        print("DEBUG: Add data button tapped..")
    }
}

extension UITableViewCell {
    func addDisclosureIndicator(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: symbolConfiguration)
        button.setImage(image, for: .normal)
        button.tintColor = .sicklySmurfBlue
        self.accessoryView = button
    }
}

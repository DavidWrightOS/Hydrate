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
    
    lazy var coreDataStack = CoreDataStack.shared
    fileprivate let dailyLogController = DailyLogController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<DailyLog> = {
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(DailyLog.date), ascending: false)]
        fetchRequest.fetchBatchSize = 50
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.mainContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "hydrate")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        fetchDailyLogs()
        configureTableView()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    // MARK: - Private Properties
    
    fileprivate static var dailyLogCell: UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "dailyLogCell")
        cell.backgroundColor = .ravenClawBlue90
        cell.tintColor = .sicklySmurfBlue
        cell.textLabel?.textColor = .undeadWhite
        cell.detailTextLabel?.textColor = UIColor.undeadWhite.withAlphaComponent(0.4)
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
    
    fileprivate func fetchDailyLogs() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    fileprivate func fetchDailyLog(for date: Date = Date()) -> DailyLog {
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        let datePredicate = NSPredicate(format: "(%K = %@)", #keyPath(DailyLog.date), date.startOfDay as NSDate)
        fetchRequest.predicate = datePredicate
        
        do {
            if let dailyLog = try CoreDataStack.shared.mainContext.fetch(fetchRequest).first {
                return dailyLog
            }
        } catch let error as NSError {
            print("Error fetching: \(error), \(error.userInfo)")
        }
        
        return DailyLog(date: date.startOfDay)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "dailyLogCell")
        if cell == nil {
            cell = DailyLogTableViewController.dailyLogCell
        }
        configure(cell: cell, for: indexPath)
        
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
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let dailyLog = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = "\(dailyLog.totalIntake) oz."
        cell.detailTextLabel?.text = dateFormatter.string(from: dailyLog.date!)
    }
    
    @objc fileprivate func addDataButtonTapped() {
        let dailyLog = dailyLogController.fetchDailyLog()
        dailyLogController.add(intakeAmount: 8, to: dailyLog)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dailyLog = fetchedResultsController.object(at: indexPath)
        let entryTableVC = EntriesTableViewController(for: dailyLog)
        navigationController?.pushViewController(entryTableVC, animated: true)
    }
}

extension UITableViewCell {
    func addDisclosureIndicator(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: UIImage.SymbolWeight.semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: symbolConfiguration)
        button.setImage(image, for: .normal)
        button.tintColor = .actionColor
        self.accessoryView = button
    }
}


// MARK: - NSFetchedResultsControllerDelegate

extension DailyLogTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            configure(cell: cell, for: indexPath)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete: tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

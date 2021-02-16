//
//  DailyLogTableViewController.swift
//  Hydrate
//
//  Created by David Wright on 9/20/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import CoreData

protocol DailyLogTableViewControllerDelegate: class {
    func addDataButtonTapped()
    func addDataButtonTapped(for date: Date)
}

class DailyLogTableViewController: UITableViewController {

    // MARK: - Properties
    
    weak var delegate: DailyLogTableViewControllerDelegate?
    
    private let dailyLogController = DailyLogController()
    
    private lazy var coreDataStack = CoreDataStack.shared
    
    private lazy var fetchedResultsController: NSFetchedResultsController<DailyLog> = {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadIntakeEntries),
                                               name: .intakeEntriesDidChangeNotificationName, object: nil)
        
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
    
    private static var dailyLogCell: UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "dailyLogCell")
        cell.backgroundColor = .ravenClawBlue90
        cell.tintColor = .sicklySmurfBlue
        cell.textLabel?.textColor = .undeadWhite
        cell.detailTextLabel?.textColor = UIColor.undeadWhite.withAlphaComponent(0.65)
        cell.addDisclosureIndicator(color: .actionColor)
        cell.selectionStyle = .none
        return cell
    }
    
    private lazy var addDataButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Add Data", style: .plain, target: self, action: #selector(didTapAddDataButton))
    }()
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    // MARK: - Private Methods
    
    private func configureTableView() {
        title = "Daily Logs"
        tableView = UITableView(frame: self.tableView.frame, style: .insetGrouped)
        tableView.backgroundColor = .ravenClawBlue
        tableView.separatorColor = .ravenClawBlue
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        setEditing(false, animated: true)
        tableView.reloadData()
    }
    
    private func fetchDailyLogs() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    private func fetchDailyLog(for date: Date = Date()) -> DailyLog {
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
    
    @objc private func loadIntakeEntries() {
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        let rowCount = sectionInfo.numberOfObjects
        
        if rowCount == 0 {
            let title = "Daily Logs"
            let subtitle = "You haven't logged any water intake data yet."
            let image = UIImage(named: "waterDropWithRingsSymbol")
            tableView.addSplashScreen(title: title, subtitle: subtitle, image: image)

        } else {
            tableView.removeSplashScreen()
        }
        
        return rowCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "dailyLogCell")
        if cell == nil {
            cell = DailyLogTableViewController.dailyLogCell
        }
        configure(cell: cell, for: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let dailyLog = fetchedResultsController.object(at: indexPath)
            dailyLogController.delete(dailyLog)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            self.navigationItem.leftBarButtonItem = self.addDataButton
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let dailyLog = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = "\(dailyLog.totalIntake) \(HydrateSettings.unit.abbreviation)"
        cell.detailTextLabel?.text = dateFormatter.string(from: dailyLog.date!)
    }
    
    @objc private func didTapAddDataButton() {
        delegate?.addDataButtonTapped()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dailyLog = fetchedResultsController.object(at: indexPath)
        let entryTableVC = EntriesTableViewController(for: dailyLog)
        entryTableVC.delegate = self
        navigationController?.pushViewController(entryTableVC, animated: true)
    }
}

extension UITableViewCell {
    func addDisclosureIndicator(color: UIColor) {
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let chevronImg = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)?
            .withTintColor(color, renderingMode: .alwaysTemplate)
        let chevron = UIImageView(image: chevronImg)
        chevron.tintColor = color
        
        let accessoryViewHeight = self.frame.height
        let customDisclosureIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 11, height: accessoryViewHeight))
        customDisclosureIndicator.addSubview(chevron)
        
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.trailingAnchor.constraint(equalTo: customDisclosureIndicator.trailingAnchor).isActive = true
        chevron.centerYAnchor.constraint(equalTo: customDisclosureIndicator.centerYAnchor).isActive = true
        
        customDisclosureIndicator.backgroundColor = .clear
        self.accessoryView = customDisclosureIndicator
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

// MARK: - EntriesTableViewControllerDelegate

extension DailyLogTableViewController: EntriesTableViewControllerDelegate {
    func addDataButtonTapped(for date: Date) {
        delegate?.addDataButtonTapped(for: date)
    }
}

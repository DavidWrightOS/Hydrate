//
//  EntriesTableViewController.swift
//  Hydrate
//
//  Created by David Wright on 9/29/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import CoreData

protocol EntriesTableViewControllerDelegate: class {
    func addDataButtonTapped(for date: Date)
}

class EntriesTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    weak var delegate: EntriesTableViewControllerDelegate?
    
    private let dailyLogController = DailyLogController()
    
    private lazy var coreDataStack = CoreDataStack.shared
    
    private var dailyLog: DailyLog!
    
    private let unit = HydrateSettings.unit
    
    private lazy var fetchedResultsController: NSFetchedResultsController<IntakeEntry> = {
        let fetchRequest: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(IntakeEntry.timestamp), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "(%K = %@)", #keyPath(IntakeEntry.dailyLog), dailyLog)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: coreDataStack.mainContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - Lifecycle
    
    init(for dailyLog: DailyLog) {
        super.init(style: .insetGrouped)
        self.dailyLog = dailyLog
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        configureTableView()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    // MARK: - Private Properties
    
    private static var intakeEntryCell: UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "intakeEntryCell")
        cell.backgroundColor = .ravenClawBlue90
        cell.tintColor = .sicklySmurfBlue
        cell.textLabel?.textColor = .undeadWhite
        cell.detailTextLabel?.textColor = UIColor.undeadWhite.withAlphaComponent(0.65)
        cell.selectionStyle = .none
        return cell
    }
    
    private lazy var addDataButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Add Data", style: .plain, target: self, action: #selector(addDataButtonTapped))
    }()
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    private var timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    // MARK: - Private Methods
    
    private func configureTableView() {
        title = dateFormatter.string(from: dailyLog.date!)
        tableView = UITableView(frame: self.tableView.frame, style: .insetGrouped)
        tableView.backgroundColor = .ravenClawBlue
        tableView.separatorColor = .ravenClawBlue
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        setEditing(false, animated: true)
        tableView.reloadData()
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
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "intakeEntryCell")
        if cell == nil {
            cell = EntriesTableViewController.intakeEntryCell
        }
        configure(cell: cell, for: indexPath)
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let intakeEntry = fetchedResultsController.object(at: indexPath)
            dailyLogController.delete(intakeEntry)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let leftBarButtonItem = editing ? self.addDataButton : nil
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        unit.abbreviationFull
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.undeadWhite.withAlphaComponent(0.5)
        }
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let intakeEntry = fetchedResultsController.object(at: indexPath)
        let intakeAmount = intakeEntry.amount * unit.conversionFactor
        cell.textLabel?.text = "\(intakeAmount.roundedString)"
        
        if let timestamp = intakeEntry.timestamp {
            cell.detailTextLabel?.text = timeFormatter.string(from: timestamp)
        } else {
            cell.detailTextLabel?.text = "--"
        }
    }
    
    @objc private func addDataButtonTapped() {
        guard let date = dailyLog.date else { return }
        delegate?.addDataButtonTapped(for: date)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension EntriesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
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
    
    func controller(_ controller:
                        NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

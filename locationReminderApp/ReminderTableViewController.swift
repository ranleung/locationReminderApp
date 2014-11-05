//
//  ReminderTableViewController.swift
//  locationReminderApp
//
//  Created by Randall Leung on 11/5/14.
//  Copyright (c) 2014 Randall. All rights reserved.
//

import UIKit
import CoreData

class ReminderTableViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        //Getting data from when iCloud data changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetCloudChanged:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: appDelegate.persistentStoreCoordinator)
        
        self.tableView.dataSource = self
        
        var fetchRequest = NSFetchRequest(entityName: "Reminder")
        //The sort descriptors specify how the objects returned when the fetch request is issued should be ordered
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "radius", ascending: true)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "longitude", ascending: true)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Reminders")
        self.fetchedResultsController.delegate = self
        
        var error: NSError?
        if !self.fetchedResultsController.performFetch(&error) {
            println("THE ERROR IS: \(error)")
        }
        
        //        self.reminders = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [Reminder]
        //        if error != nil {
        //            println(error?.localizedDescription)
        //        } else {
        //            self.tableView.reloadData()
        //        }
    }
    
    func didGetCloudChanged(notification: NSNotification) {
        self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("REMINDER_CELL", forIndexPath: indexPath) as UITableViewCell
        
        let reminder = self.fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder
        cell.textLabel.text = reminder.name
        
        return cell
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    



}

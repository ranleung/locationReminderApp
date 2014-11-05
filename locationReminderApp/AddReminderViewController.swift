//
//  AddReminderViewController.swift
//  locationReminderApp
//
//  Created by Randall Leung on 11/3/14.
//  Copyright (c) 2014 Randall. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AddReminderViewController: UIViewController {
    
    var locationManager: CLLocationManager!
    var selectedAnnotation: MKAnnotation!
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        //The set of shared regions monitored by all location manager objects. (read-only)
        //let regionSet = self.locationManager.monitoredRegions
        //let regions = regionSet.allObjects
    }

    @IBAction func addReminderButton(sender: AnyObject) {
        
        //defines the location and boundaries for a circular geographic region
        var geoRegion = CLCircularRegion(center: selectedAnnotation.coordinate, radius: 4000.0, identifier: "TestRegion")
        self.locationManager.startMonitoringForRegion(geoRegion)
        
        //Inserting into CoreData
        var newReminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.managedObjectContext) as Reminder
        newReminder.name = "TestRegion"
        newReminder.latitude = geoRegion.center.latitude
        newReminder.longitude = geoRegion.center.latitude
        newReminder.radius = geoRegion.radius
        newReminder.date = NSDate()
        
        var error: NSError?
        self.managedObjectContext.save(&error)
        
        if error != nil {
            println("ERROR: \(error?.localizedDescription)")
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("REMINDER_ADDED", object: self, userInfo: ["region": geoRegion])
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

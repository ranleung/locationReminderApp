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
  
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var reminderNameLabel: UITextField!
    
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Reminder"
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        //The set of shared regions monitored by all location manager objects. (read-only)
        //let regionSet = self.locationManager.monitoredRegions
        //let regions = regionSet.allObjects
        
        self.lat = self.selectedAnnotation.coordinate.latitude
        self.lon = self.selectedAnnotation.coordinate.longitude
        
        var location = CLLocation(latitude: lat!, longitude: lon!)
        
        //Reverse Geocoding
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:{(placemarks, error) in
            if error != nil {
                println(error)
            } else {
                let p = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                
                //Additional street-level information if exists.
                var subThoroughfare: String
                if (p.subThoroughfare != nil) {
                    subThoroughfare = p.subThoroughfare
                } else {
                    subThoroughfare = ""
                }
                var thoroughfare: String
                if (p.thoroughfare != nil) {
                    thoroughfare = p.thoroughfare
                } else {
                    thoroughfare = ""
                }
                self.address = "\(subThoroughfare) \(thoroughfare) \n \(p.subLocality) \n \(p.subAdministrativeArea) \n \(p.postalCode) \n \(p.country)"
                
                self.addressLabel.text = self.address
            }
        })
        
        var latDelta: CLLocationDegrees = 0.01
        var lonDelta: CLLocationDegrees = 0.01
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var loc2D: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.lat!, self.lon!)
        var region: MKCoordinateRegion = MKCoordinateRegionMake(loc2D, span)
        self.mapView.setRegion(region, animated: true)
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = loc2D
        self.mapView.addAnnotation(annotation)
        
    }

    @IBAction func addReminderButton(sender: AnyObject) {
        
        if self.reminderNameLabel.text == nil {
            self.reminderNameLabel.text == ""
        }
        
        //defines the location and boundaries for a circular geographic region
        var geoRegion = CLCircularRegion(center: selectedAnnotation.coordinate, radius: 4000.0, identifier: self.reminderNameLabel.text)
        self.locationManager.startMonitoringForRegion(geoRegion)
        
        //Inserting into CoreData
        var newReminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.managedObjectContext) as Reminder
        newReminder.name = self.reminderNameLabel.text
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
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

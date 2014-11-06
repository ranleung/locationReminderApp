//
//  ViewController.swift
//  locationReminderApp
//
//  Created by Randall Leung on 11/3/14.
//  Copyright (c) 2014 Randall. All rights reserved.
//

import UIKit
import MapKit

//Need to go into Info.plist to allow access to location services

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet var mapView: MKMapView!
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Map"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reminderAdded:", name: "REMINDER_ADDED", object: nil)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressMap:")
        longPress.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPress)
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        
        //Returns the app’s authorization status for using location services.
        switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus {
        case .Authorized:
            println("Authorized")
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        case .NotDetermined:
            println("Not Determined")
            //Request permission to use location services
            self.locationManager.requestAlwaysAuthorization()
        case .Restricted:
            println("Restricted")
        case .Denied:
            println("Denied")
        default:
            println("Default")
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //Finds User Location
    @IBAction func findMeButton(sender: AnyObject) {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        var loc2D: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.lat!, self.lon!)
        
        let region = MKCoordinateRegionMake(loc2D, MKCoordinateSpanMake(0.01, 0.01))
        let mapRegion = self.mapView.regionThatFits(region)
        self.mapView.setRegion(mapRegion, animated: true)
        
    }
    
    func didLongPressMap(sender: UILongPressGestureRecognizer) {
        //println("Long pressed")
        
        if sender.state == UIGestureRecognizerState.Began {
            let touchPoint = sender.locationInView(self.mapView)
            let touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            println("Lat: \(touchCoordinate.latitude) and Long: \(touchCoordinate.longitude)")
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Add Reminder"
            self.mapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegionMake(touchCoordinate, MKCoordinateSpanMake(0.01, 0.01))
            let mapRegion = self.mapView.regionThatFits(region)
            self.mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "ANNOTATION")
        annotationView.animatesDrop = true
        //To display extra information in a callout bubble.
        annotationView.canShowCallout = true
        let addButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
        annotationView.rightCalloutAccessoryView = addButton
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let reminderVC = self.storyboard?.instantiateViewControllerWithIdentifier("REMINDER_VC") as AddReminderViewController
        reminderVC.locationManager = self.locationManager
        reminderVC.selectedAnnotation = view.annotation
        self.presentViewController(reminderVC, animated: true, completion: nil)
    }
    
    //Tells the delegate that the authorization status for the application changed.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            println("Changed to Authorized")
            //Starts the generation of updates that report the user’s current location.
            self.locationManager.startUpdatingLocation()
        default:
            println("Default on authorization change")
        }
    }
    
    //Handling fail for location, ie: user does not agree with location servcies
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("The location update has failed, error is: \(error)")
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("Entered Location")
        
        if (UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
            var notification = UILocalNotification()
            notification.alertAction = "You've entered a monitored region!"
            notification.alertBody = "This is your reminder, you've just entered a monitored region!"
            notification.fireDate = NSDate()
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("Left Location")
    }
    
    //Tells the delegate that new location data is available.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if let location = locations.last as? CLLocation {
            //println("Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)")
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
        }
    }
    
    //Asks the delegate for a renderer object to use when drawing the specified overlay.
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        
        renderer.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.10)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 0.5
        
        return renderer
    }
    
    func reminderAdded(notification: NSNotification) {
        //The user information dictionary associated with the receiver.
        let userInfo = notification.userInfo!
        let geoRegion = userInfo["region"] as CLCircularRegion
        
        let overlay = MKCircle(centerCoordinate: geoRegion.center, radius: geoRegion.radius)
        self.mapView.addOverlay(overlay)
    }

}







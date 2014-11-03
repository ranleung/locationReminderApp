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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressMap:")
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
    
    func didLongPressMap(sender: UILongPressGestureRecognizer) {
        //println("Long pressed")
        
        if sender.state == UIGestureRecognizerState.Began {
            let touchPoint = sender.locationInView(self.mapView)
            let touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            println("Lat: \(touchCoordinate.latitude) and Long: \(touchCoordinate.longitude)")
            var annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Add Reminder"
            self.mapView.addAnnotation(annotation)
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
            //self.locationManager.startUpdatingLocation()
        default:
            println("Default on authorization change")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("Entered Location")
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("Left Location")
    }
    
    //Tells the delegate that new location data is available.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Location Update!")
        
        if let location = locations.last as? CLLocation {
            println("Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


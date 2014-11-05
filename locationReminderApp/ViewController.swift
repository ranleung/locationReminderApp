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
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("Left Location")
    }
    
    //Tells the delegate that new location data is available.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if let location = locations.last as? CLLocation {
            //println("Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)")
            
            //Reverse Geocoding
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                if error != nil {
                    println(error)
                } else {
                    let p = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                    
                    //Additional street-level information for the placemark.
                    var subThoroughfare: String
                    if (p.subThoroughfare != nil) {
                        subThoroughfare = p.subThoroughfare
                    } else {
                        subThoroughfare = ""
                    }
                    
                    //println("The address is: \(subThoroughfare) \(p.thoroughfare) \n \(p.subLocality) \n \(p.subAdministrativeArea) \n \(p.postalCode) \n \(p.country)")
                }
            })
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







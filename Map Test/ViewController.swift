//
//  ViewController.swift
//  Map Test
//
//  Created by Greg Hochsprung on 2/18/16.
//  Copyright © 2016 Greg Hochsprung. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var gotLocation: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapView.delegate = self;
        gotLocation = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            startMonitoringLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startMonitoringLocation() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
}


// MARK: MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "MyCustomAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let venue = annotation as? Venue
        let imageView = UIImageView(image: venue?.thumbnailImage)
        annotationView?.detailCalloutAccessoryView = imageView
        return annotationView
    }
}


// MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        startMonitoringLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!gotLocation) {
            gotLocation = true
            let location:CLLocationCoordinate2D = locations.last!.coordinate
            let region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.01, 0.01))
            mapView.setRegion(region, animated: true)
            manager.stopUpdatingLocation()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            Server.init().getVenuesForLatitude(location.latitude, longitude: location.longitude) {
                (result: [Venue], latRange: Double) in
                let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mapView.removeAnnotations(annotationsToRemove)
                    self.mapView.addAnnotations(result)
                    let newRegion = MKCoordinateRegionMake(location, MKCoordinateSpanMake(latRange, latRange))
                    self.mapView.setRegion(newRegion, animated: true)
                })
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
        
    }
}
//
//  LocationVC.swift
//  Treads
//
//  Created by Mahesh on 06/11/20.
//

import UIKit
import MapKit
import CoreLocation

class LocationVC: UIViewController, MKMapViewDelegate {
    var manager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager?.desiredAccuracy  = kCLLocationAccuracyBest
        manager?.activityType = .fitness
    }
    
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            manager?.requestWhenInUseAuthorization()
        }
    }
}
//extension LocationVC : CLLocationManagerDelegate {
//    
//}

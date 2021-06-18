//
//  BeginRunVC.swift
//  Treads
//
//  Created by Mahesh on 30/10/20.
//

import UIKit
import MapKit
import RealmSwift

class BeginRunVC: LocationVC {

    @IBOutlet weak var lastRunDetailView: UIView!
    @IBOutlet weak var lastRunCloseBtn: UIButton!
    
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
        mapView.showsUserLocation = true
    }
    override func viewDidAppear(_ animated: Bool) {
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        manager?.delegate = self
        manager?.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    func centerMapOnUserLocation() {
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        
        self.mapView.region = coordinateRegion
    }
    func centerMapOnPreviousRoute(locations : List<Location>) -> MKCoordinateRegion {
        guard let initalLocation = locations.first else { return MKCoordinateRegion() }
        
        var minLat = initalLocation.latitude
        var minLong = initalLocation.longitude
        
        var maxLat = minLat
        var maxLong = minLong
        
        for location in locations {
            minLat = min(minLat, location.latitude)
            minLong = min(minLong, location.longitude)
            
            maxLat = max(maxLat, location.latitude)
            maxLong = max(maxLong, location.longitude)
        }
        let coordinate = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
        
        return MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta:  (maxLong - minLong) * 1.4))
        
    }
     func setupMapView() {
        if let overlay = addLastRunToMap() {
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            
            mapView.addOverlay(overlay)
            lastRunDetailView.isHidden = false
        } else {
            centerMapOnUserLocation()
            lastRunDetailView.isHidden = true
        }
    }

    func addLastRunToMap() -> MKPolyline? {
        guard let lastRun = Run.getAllRuns()?.first else { return nil }
        
        paceLbl.text = lastRun.pace.formatTimeDurationToString()
        distanceLbl.text = "\(lastRun.distance.metersToMiles(places: 2)) mi"
        durationLbl.text = lastRun.duration.formatTimeDurationToString()
        
        var coordinate = [CLLocationCoordinate2D]()
        
        for location in lastRun.location {
            coordinate.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        mapView.userTrackingMode = .none
        
        guard let lastLocations = Run.getRun(byId: lastRun.id)?.location else { return MKPolyline() }
        
        mapView.setRegion(centerMapOnPreviousRoute(locations: lastLocations), animated: true)
        
        return MKPolyline(coordinates: coordinate, count: lastRun.location.count)
    }
    
    
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    @IBAction func lastRunCloseBtnPressed(_ sender: Any) {
        lastRunDetailView.isHidden = true
        centerMapOnUserLocation()
    }
}
extension BeginRunVC : CLLocationManagerDelegate {
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            checkLocationAuthStatus()
//            mapView.userTrackingMode = .follow
        }
    }
    
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer() }
        
        let render = MKPolylineRenderer(polyline: polyline)
        render.strokeColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        render.lineWidth = 4
        
        return render
    }
    
}

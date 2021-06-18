//
//  CurrentRunVC.swift
//  Treads
//
//  Created by Mahesh on 06/11/20.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift

class CurrentRunVC: LocationVC, UIGestureRecognizerDelegate {

//    Outlets
    
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    @IBOutlet weak var swipeBgImgView: UIImageView!
    @IBOutlet weak var sliderImgView: UIImageView!
    @IBOutlet weak var pauseBtn: UIButton!
    
//    variables
    
    fileprivate var startLocation : CLLocation?
    fileprivate var lastLocation : CLLocation?
    
    fileprivate var runDistance : Double = 0.0
    
    fileprivate var counter = 0
    fileprivate var timer = Timer()
    fileprivate var pace = 0
    
    fileprivate var coordinateLocations = List<Location>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeGesture = UIPanGestureRecognizer()
        swipeGesture.addTarget(self, action: #selector(endRunSwiped(_:)))
        sliderImgView.addGestureRecognizer(swipeGesture)
        sliderImgView.isUserInteractionEnabled = true
        swipeGesture.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        manager?.distanceFilter = 10
        startRun()
    }
    
    func startRun() {
        manager?.startUpdatingLocation()
        startTimer()
        pauseBtn.setImage(#imageLiteral(resourceName: "pauseButton"), for: .normal)
    }
    
    func endRun() {
        Run.addRunToRealm(pace: pace, distance: runDistance, duration: counter, locations: self.coordinateLocations)
        pauseRun()
    }
    
    func startTimer() {
        durationLbl.text = "\(counter.formatTimeDurationToString())"
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CurrentRunVC.updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounter() {
        counter += 1
        durationLbl.text = "\(counter.formatTimeDurationToString())"
    }
    
    func calculatePace(time seconds : Int, miles : Double) -> String {
        pace = Int(Double(seconds) / miles)
        return pace.formatTimeDurationToString()
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        if timer.isValid {
            pauseRun()
        } else {
            startRun()
        }
    }
    
    func pauseRun() {
        timer.invalidate()
        manager?.stopUpdatingLocation()
        pauseBtn.setImage(#imageLiteral(resourceName: "resumeButton") , for: .normal)
        startLocation = nil
        lastLocation = nil
    }
    
    @objc func endRunSwiped(_ sender : UIPanGestureRecognizer) {
        let minAdjust : CGFloat = 80
        let maxAdjust : CGFloat = 130
        
        if let sliderView = sender.view {
            if sender.state == .began || sender.state == .changed {
                let translation = sender.translation(in: self.view)
                if (sliderView.center.x >= (swipeBgImgView.center.x - minAdjust)) && sliderView.center.x <= (swipeBgImgView.center.x + maxAdjust) {
                    sliderView.center.x = sliderView.center.x + translation.x
                } else if (sliderView.center.x >= (swipeBgImgView.center.x + maxAdjust)) {
                    sliderView.center.x = swipeBgImgView.center.x + maxAdjust
                    endRun()
//                    end run code
                    dismiss(animated: true, completion: nil)
                } else {
                    sliderView.center.x = swipeBgImgView.center.x - minAdjust
                }
                sender.setTranslation(CGPoint.zero, in: self.view)
            } else if sender.state == .ended {
                UIView.animate(withDuration: 0.2) {
                    sliderView.center.x = self.swipeBgImgView.center.x - minAdjust
                }
            }
        }
    }
}


extension CurrentRunVC : CLLocationManagerDelegate {
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            checkLocationAuthStatus()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            let newLocation = Location(latitude: Double(location.coordinate.latitude), longitude: Double(location.coordinate.longitude))
            self.coordinateLocations.insert(newLocation, at: 0)
            
            runDistance += (lastLocation?.distance(from: location))!
            distanceLbl.text = "\(runDistance.metersToMiles(places: 2))"
            if counter > 0 && runDistance > 0 {
                paceLbl.text = calculatePace(time: counter, miles: runDistance.metersToMiles(places: 2))
            }
        }
        lastLocation = locations.last
    }
}

//
//  Run.swift
//  Treads
//
//  Created by Mahesh on 06/11/20.
//

import Foundation
import RealmSwift

class Run : Object {
    @objc dynamic public private(set) var id = ""
    @objc dynamic public private(set) var pace = 0
    @objc dynamic public private(set) var distance = 0.0
    @objc dynamic public private(set) var duration = 0
    @objc dynamic public private(set) var date = NSDate()
    public private(set) var location = List<Location>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func indexedProperties() -> [String] {
        return ["pace", "date", "duration"]
    }
    
    convenience init(pace: Int, distance : Double, duration : Int, location: List<Location>) {
        self.init()
        self.id = UUID().uuidString.lowercased()
        self.date = NSDate()
        self.pace = pace
        self.duration = duration
        self.distance = distance
        self.location = location
    }
    
    static func addRunToRealm(pace : Int, distance : Double, duration : Int, locations : List<Location>) {
        REALM_QUEUE.async {
            let run = Run(pace: pace, distance: distance, duration: duration, location: locations)
            do {
                let realm = try Realm(configuration: RealmConfig.runDataConfig)
                try realm.write({ () -> Run in
                    realm.add(run)
                    try realm.commitWrite()
                    return run
                })
            } catch let error {
                debugPrint("error adding run to realm : ", error.localizedDescription)
            }
        }
    }
    
    static func getAllRuns() -> Results<Run>? {
        do {
            let realm = try Realm(configuration: RealmConfig.runDataConfig)
            var runs = realm.objects(Run.self)
            runs = runs.sorted(byKeyPath: "date", ascending: false)
            return runs
        } catch let error {
            debugPrint("error getting all runs : \(error.localizedDescription)")
            return nil
        }
    }
    
    static func getRun(byId id : String) -> Run? {
        
        do {
            let realm = try Realm(configuration: RealmConfig.runDataConfig)
            let run = realm.object(ofType: Run.self, forPrimaryKey: id)
            return run
        } catch let error {
            return nil
            debugPrint("get run by id error : \(error.localizedDescription)")
        }
    }
}

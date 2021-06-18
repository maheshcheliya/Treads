//
//  Location.swift
//  Treads
//
//  Created by Mahesh on 06/11/20.
//

import Foundation
import RealmSwift

class Location : Object {
    @objc dynamic public private(set) var latitude = 0.0
    @objc dynamic public private(set) var longitude = 0.0
    
    convenience init(latitude : Double, longitude : Double) {
        self.init()
        
        self.latitude = latitude
        self.longitude = longitude
    }
}

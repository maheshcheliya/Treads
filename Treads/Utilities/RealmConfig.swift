//
//  RealmConfig.swift
//  Treads
//
//  Created by Mahesh on 06/11/20.
//

import Foundation
import RealmSwift

class RealmConfig {
    static var runDataConfig : Realm.Configuration {
        let realmPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(REALM_RUN_CONFIG)
        print("realmPath : ", realmPath)
        let config = Realm.Configuration(
            fileURL: realmPath,
            schemaVersion: 0) { (migration, oldSchemaVersion) in
            if(oldSchemaVersion < 0) {
//                Nothing to do
//                Realm will automatically detect new properties and remove properties
            }
        }
        return config
    }
}

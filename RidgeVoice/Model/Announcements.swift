//
//  Announcements.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/12/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import Foundation

import Foundation
import RealmSwift
import Realm

class Announcements: Object {
    @objc dynamic var id : String?
    @objc dynamic var user : User?
    @objc dynamic var timeStamp: String?
    @objc dynamic var isAdmin: Bool = false
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    func writeToRealm() {
        try! annRealm.write {
            annRealm.add(self)
        }
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.user?.dictionaryRepresentation(), forKey: "user")
        dictionary.setValue(self.timeStamp, forKey: "timeStamp")
        dictionary.setValue(self.isAdmin, forKey: "isAdmin")
        return dictionary
    }
    
}

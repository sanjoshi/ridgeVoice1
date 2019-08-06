//
//  Service.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 8/4/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import Foundation
import RealmSwift

class Service: Object {
    
    @objc dynamic var id : String?
    @objc dynamic var name : String?
    @objc dynamic var service : String?
    @objc dynamic var user : User?
    @objc dynamic var contact: String?
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    func writeToRealm() {
        try! serviceRealm.write {
            serviceRealm.add(self, update: Realm.UpdatePolicy.modified)
        }
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.name, forKey: "name")
        dictionary.setValue(self.service, forKey: "service")
        dictionary.setValue(self.contact, forKey: "contact")
        dictionary.setValue(self.user?.dictionaryRepresentation(), forKey: "user")
        return dictionary
    }
    
}

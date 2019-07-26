//
//  Member.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/13/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import Foundation
import RealmSwift

class Member: Object {
    
    @objc dynamic var id : String?
    @objc dynamic var memberName : String?
    @objc dynamic var user : User?
    @objc dynamic var contactNo: String?
    @objc dynamic var position: String?
    @objc dynamic var memberPictureURL: String?
    @objc dynamic var memberEmail: String?
    var count = RealmOptional<Int>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    func writeToRealm() {
        try! memberRealm.write {
            memberRealm.add(self, update: Realm.UpdatePolicy.modified)
        }
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.memberName, forKey: "memberName")
        dictionary.setValue(self.position, forKey: "position")
        dictionary.setValue(self.contactNo, forKey: "contactNo")
        dictionary.setValue(self.user?.dictionaryRepresentation(), forKey: "user")
        dictionary.setValue(self.count.value, forKey: "count")
        dictionary.setValue(self.memberPictureURL, forKey: "memberPictureURL")
        dictionary.setValue(self.memberEmail, forKey: "memberEmail")
        return dictionary
    }
    
  }

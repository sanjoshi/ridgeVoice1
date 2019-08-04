//
//  RidgeIssues.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 8/2/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import Foundation
import RealmSwift

class RidgeIssues: Object {
    
    @objc dynamic var id : String?
    @objc dynamic var issueTitle : String?
    @objc dynamic var issueDesc : String?
    @objc dynamic var user : User?
    @objc dynamic var timeStamp: String?
    @objc dynamic var issueDate : String?
    @objc dynamic var issueType : String?
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    func writeToRealm() {
        try! ridgeIssueRealm.write {
            ridgeIssueRealm.add(self, update: Realm.UpdatePolicy.modified)
        }
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.issueTitle, forKey: "issueTitle")
        dictionary.setValue(self.issueType, forKey: "issueType")
        dictionary.setValue(self.issueDesc, forKey: "issueDesc")
        dictionary.setValue(self.issueDate, forKey: "issueDate")
        dictionary.setValue(self.user?.dictionaryRepresentation(), forKey: "user")
        dictionary.setValue(self.timeStamp, forKey: "timeStamp")
        return dictionary
    }
    
}

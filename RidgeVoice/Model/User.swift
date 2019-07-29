//
//  User.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/10/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import Foundation
import RealmSwift

public class User: Object {
    
    @objc dynamic var id : String?
    @objc dynamic var firstName : String?
    @objc dynamic var lastName : String?
    @objc dynamic var contactNo: String?
    @objc dynamic var email: String?
    @objc dynamic var profilePictureURL: String?
    @objc dynamic var address: String?
    @objc dynamic var type: String?
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.firstName, forKey: "firstName")
        dictionary.setValue(self.lastName, forKey: "lastName")
        dictionary.setValue(self.contactNo, forKey: "contactNo")
        dictionary.setValue(self.email, forKey: "email")
        dictionary.setValue(self.profilePictureURL, forKey: "profilePictureURL")
        dictionary.setValue(self.address, forKey: "address")
        dictionary.setValue(self.type, forKey: "type")        
        return dictionary
    }
    
}

//
//  Item.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 8/3/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import Foundation
import RealmSwift

public class Item: Object {
    
    @objc dynamic var id : String?
    @objc dynamic var itemName : String?
    @objc dynamic var itemDesc : String?
    @objc dynamic var itemPrice: String?
    @objc dynamic var contactDetails: String?
    @objc dynamic var itemImage2: String?
    @objc dynamic var itemImage1: String?
    @objc dynamic var user : User?
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    func writeToRealm() {
        try! saleItemRealm.write {
            saleItemRealm.add(self, update: Realm.UpdatePolicy.modified)
        }
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.user?.dictionaryRepresentation(), forKey: "user")
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.itemName, forKey: "itemName")
        dictionary.setValue(self.itemDesc, forKey: "itemDesc")
        dictionary.setValue(self.itemPrice, forKey: "itemPrice")
        dictionary.setValue(self.contactDetails, forKey: "contactDetails")
        dictionary.setValue(self.itemImage1, forKey: "itemImage1")
        dictionary.setValue(self.itemImage2, forKey: "itemImage2")
        return dictionary
    }
    
}

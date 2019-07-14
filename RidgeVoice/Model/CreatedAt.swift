//
//  CreatedAt.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/14/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import Foundation
import RealmSwift

class CreatedAt: Object {
    
    @objc dynamic var date = 0
    @objc dynamic var day = 0
    @objc dynamic var hours = 0
    @objc dynamic var minutes = 0
    @objc dynamic var month = 0
    @objc dynamic var seconds = 0
    @objc dynamic var time = 0
    @objc dynamic var timezoneOffset = 0
    @objc dynamic var year = 0
    
    
    func getCurrentTime() -> CreatedAt {
        
        let createAt = CreatedAt()
        let date1 = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone, .weekday, .weekdayOrdinal], from: date1)
        
        createAt.day = components.weekday! - 1
        createAt.date = components.day!
        createAt.hours = components.hour!
        createAt.minutes = components.minute!
        createAt.month = components.month!
        createAt.seconds = components.second!
        createAt.time = 123123
        createAt.timezoneOffset = (components.timeZone?.secondsFromGMT())!
        createAt.year = components.year!
        
        return createAt
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.date, forKey: "date")
        dictionary.setValue(self.day, forKey: "day")
        dictionary.setValue(self.hours, forKey: "hours")
        dictionary.setValue(self.minutes, forKey: "minutes")
        dictionary.setValue(self.month, forKey: "month")
        dictionary.setValue(self.seconds, forKey: "seconds")
        dictionary.setValue(self.time, forKey: "time")
        dictionary.setValue(self.timezoneOffset, forKey: "timezoneOffset")
        dictionary.setValue(self.year, forKey: "year")
        
        return dictionary
    }
    
    
    
}

//
//  ScheduleCoder.swift
//  SumDU
//
//  Created by Юра on 30.01.16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Class for coding and decoding Schedule records
class ScheduleCoder: NSObject, NSCoding {
    
    // MARK: - Variables
    
    /// Schedule instance
    var schedule: Schedule?
    
    /// Initializer for ScheduleCoder class
    init(schedule: Schedule) {
        self.schedule = schedule
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let pairName = aDecoder.decodeObjectForKey("pairName") as? String,
            let pairTime = aDecoder.decodeObjectForKey("pairTime") as? String,
            let pairType = aDecoder.decodeObjectForKey("pairType") as? String,
            let auditoriumName = aDecoder.decodeObjectForKey("auditoriumName") as? String,
            let teacherName = aDecoder.decodeObjectForKey("teacherName") as? String,
            let groupName = aDecoder.decodeObjectForKey("groupName") as? String,
            let pairDate = aDecoder.decodeObjectForKey("pairDate") as? NSDate,
            let pairOrderName = aDecoder.decodeObjectForKey("pairOrderName") as? String,
            let dayOfWeek = aDecoder.decodeObjectForKey("dayOfWeek") as? String{
                self.schedule = Schedule(pairName: pairName, pairTime: pairTime, pairType: pairType, auditoriumName: auditoriumName, teacherName: teacherName, groupName: groupName, pairDate: pairDate, pairOrderName: pairOrderName, dayOfWeek: dayOfWeek)
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(schedule?.pairName, forKey: "pairName")
        aCoder.encodeObject(schedule?.pairTime, forKey: "pairTime")
        aCoder.encodeObject(schedule?.pairType, forKey: "pairType")
        aCoder.encodeObject(schedule?.auditoriumName, forKey: "auditoriumName")
        aCoder.encodeObject(schedule?.teacherName, forKey: "teacherName")
        aCoder.encodeObject(schedule?.groupName, forKey: "groupName")
        aCoder.encodeObject(schedule?.pairDate, forKey: "pairDate")
        aCoder.encodeObject(schedule?.pairOrderName, forKey: "pairOrderName")
        aCoder.encodeObject(schedule?.dayOfWeek, forKey: "dayOfWeek")
    }
}



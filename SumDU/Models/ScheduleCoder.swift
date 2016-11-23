//
//  ScheduleCoder.swift
//  SumDU
//
//  Created by Юра on 30.01.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Class for coding and decoding Schedule records
class ScheduleCoder: NSObject, NSCoding {
  
  // MARK: - Variables
  
  /// Schedule instance
  var schedule: Schedule?
  
  // MARK: - Lifecycle
  
  /// Initializer for ScheduleCoder class
  init(schedule: Schedule) {
    self.schedule = schedule
  }
  
  required init?(coder aDecoder: NSCoder) {
    if let pairName = aDecoder.decodeObject(forKey: "pairName") as? String,
      let pairTime = aDecoder.decodeObject(forKey: "pairTime") as? String,
      let pairType = aDecoder.decodeObject(forKey: "pairType") as? String,
      let auditoriumName = aDecoder.decodeObject(forKey: "auditoriumName") as? String,
      let teacherName = aDecoder.decodeObject(forKey: "teacherName") as? String,
      let groupName = aDecoder.decodeObject(forKey: "groupName") as? String,
      let pairDate = aDecoder.decodeObject(forKey: "pairDate") as? Date,
      let pairOrderName = aDecoder.decodeObject(forKey: "pairOrderName") as? String,
      let dayOfWeek = aDecoder.decodeObject(forKey: "dayOfWeek") as? String{
      self.schedule = Schedule(pairName: pairName, pairTime: pairTime, pairType: pairType, auditoriumName: auditoriumName, teacherName: teacherName, groupName: groupName, pairDate: pairDate, pairOrderName: pairOrderName, dayOfWeek: dayOfWeek)
    }
  }
  
  // MARK: - Public interface
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(schedule?.pairName, forKey: "pairName")
    aCoder.encode(schedule?.pairTime, forKey: "pairTime")
    aCoder.encode(schedule?.pairType, forKey: "pairType")
    aCoder.encode(schedule?.auditoriumName, forKey: "auditoriumName")
    aCoder.encode(schedule?.teacherName, forKey: "teacherName")
    aCoder.encode(schedule?.groupName, forKey: "groupName")
    aCoder.encode(schedule?.pairDate, forKey: "pairDate")
    aCoder.encode(schedule?.pairOrderName, forKey: "pairOrderName")
    aCoder.encode(schedule?.dayOfWeek, forKey: "dayOfWeek")
  }
}

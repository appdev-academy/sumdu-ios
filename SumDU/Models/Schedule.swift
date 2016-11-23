//
//  Schedule.swift
//  SumDU
//
//  Created by Yura Voevodin on 01.12.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Enumeration of all available response parameters

enum ScheduleResponseParameters: String {
  case PairName = "ABBR_DISC"
  case PairTime = "TIME_PAIR"
  case PairType = "NAME_STUD"
  case AuditoriumName = "NAME_AUD"
  case TeacherName = "NAME_FIO"
  case GroupName = "NAME_GROUP"
  
  case PairDate = "DATE_REG"
  case PairOrderName = "NAME_PAIR"
  case DayOfWeek = "NAME_WDAY"
}

// MARK: - class of schedule

class Schedule {
  
  // MARK: - Variables
  
  /// Name of pair
  var pairName: String
  
  /// Pair start time
  var pairTime: String
  
  /// Type of pair
  var pairType: String
  
  /// Name of auditory where is pair will be
  var auditoriumName: String
  
  /// Name of a teacher who spend a pair
  var teacherName: String
  
  /// Name of group that will go on pair
  var groupName: String
  
  
  /// Date of pair
  var pairDate: Date
  
  /// Human pair order
  var pairOrderName: String
  
  /// Day of week for pair
  var dayOfWeek: String
  
  var scheduleCoder: ScheduleCoder {
    get {
      return ScheduleCoder(schedule: self)
    }
  }
  
  // MARK: - Lifecycle
  
  /// Initialize Schedule with single JSON schedule record
  init?(record: JSON) {
    
    // Set default values (probably bug in Xcode, can't return nil on failable initializer)
    self.pairName = ""
    self.pairTime = ""
    self.pairType = ""
    self.auditoriumName = ""
    self.teacherName = ""
    self.groupName = ""
    
    self.pairDate = Date()
    self.pairOrderName = ""
    self.dayOfWeek = ""
    
    if let pairName = record[ScheduleResponseParameters.PairName.rawValue].string {
      self.pairName = pairName
    } else {
      return nil
    }
    
    if let pairTime = record[ScheduleResponseParameters.PairTime.rawValue].string {
      self.pairTime = pairTime
    } else {
      return nil
    }
    
    if let pairType = record[ScheduleResponseParameters.PairType.rawValue].string {
      self.pairType = pairType
    } else {
      return nil
    }
    
    if let auditoriumName = record[ScheduleResponseParameters.AuditoriumName.rawValue].string {
      self.auditoriumName = auditoriumName
    } else {
      return nil
    }
    
    if let teacherName = record[ScheduleResponseParameters.TeacherName.rawValue].string {
      self.teacherName = teacherName
    } else {
      return nil
    }
    
    if let groupName = record[ScheduleResponseParameters.GroupName.rawValue].string {
      self.groupName = groupName
    } else {
      return nil
    }
    
    
    
    if let pairDate = record[ScheduleResponseParameters.PairDate.rawValue].string {
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd.MM.yyyy"
      if let date = dateFormatter.date(from: pairDate) {
        self.pairDate = date
      } else {
        return nil
      }
      
    } else {
      return nil
    }
    
    if let pairOrderName = record[ScheduleResponseParameters.PairOrderName.rawValue].string {
      self.pairOrderName = pairOrderName
    } else {
      return nil
    }
    
    if let dayOfWeek = record[ScheduleResponseParameters.DayOfWeek.rawValue].string {
      self.dayOfWeek = dayOfWeek
    } else {
      return nil
    }
  }
  
  /// Initialize with all Schedule params (use in ScheduleCoder)
  init(pairName: String, pairTime: String, pairType: String, auditoriumName: String, teacherName: String, groupName: String, pairDate: Date, pairOrderName: String, dayOfWeek: String) {
    
    self.pairName = pairName
    self.pairTime = pairTime
    self.pairType = pairType
    self.auditoriumName = auditoriumName
    self.teacherName = teacherName
    self.groupName = groupName
    self.pairDate = pairDate
    self.pairOrderName = pairOrderName
    self.dayOfWeek = dayOfWeek
  }
}

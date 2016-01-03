//
//  Schedule.swift
//  SumDU
//
//  Created by Yura on 01.12.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Enumeration of all available response parameters

enum ScheduleResponseParameters: String {
    case PairTime = "TIME_PAIR"
    case PairDate = "DATE_REG"
    case PairOrderName = "NAME_PAIR"
    case GroupName = "NAME_GROUP"
    case AuditoriumName = "NAME_AUD"
    case DayOfWeek = "NAME_WDAY"
    case TeacherName = "NAME_FIO"
}

// MARK: - class of schedule

class Schedule {
    
    /// Pair start time
    var pairTime: String
    
    /// Date of pair
    var pairDate: String
    
    /// Human pair order
    var pairOrderName: String
    
    /// Name of group that will go on pair
    var groupName: String
    
    /// Name of auditory where is pair will be
    var auditoriumName: String
    
    /// Day of week for pair
    var dayOfWeek: String
    
    /// Name of a teacher who spend a pair
    var teacherName: String
    
    /**
     Initializer for schedule class
     
     - parameter record:  JSON type parameter with single schedule record
     */
    init?(record: JSON) {
        
        // Set default values (probably bug in Xcode, can't return nil on failable initializer)
        self.pairTime = ""
        self.pairDate = ""
        self.pairOrderName = ""
        self.groupName = ""
        self.auditoriumName = ""
        self.dayOfWeek = ""
        self.teacherName = ""
        
        if let pairTime = record[ScheduleResponseParameters.PairTime.rawValue].string {
            self.pairTime = pairTime
        } else {
            return nil
        }
        
        if let pairDate = record[ScheduleResponseParameters.PairDate.rawValue].string {
            self.pairDate = pairDate
        } else {
            return nil
        }
        
        if let pairOrderName = record[ScheduleResponseParameters.PairOrderName.rawValue].string {
            self.pairOrderName = pairOrderName
        } else {
            return nil
        }
        
        if let groupName = record[ScheduleResponseParameters.GroupName.rawValue].string {
            self.groupName = groupName
        } else {
            return nil
        }
        
        if let auditoriumName = record[ScheduleResponseParameters.AuditoriumName.rawValue].string {
            self.auditoriumName = auditoriumName
        } else {
            return nil
        }
        
        if let dayOfWeek = record[ScheduleResponseParameters.DayOfWeek.rawValue].string {
            self.dayOfWeek = dayOfWeek
        } else {
            return nil
        }
        
        if let teacherName = record[ScheduleResponseParameters.TeacherName.rawValue].string {
            self.teacherName = teacherName
        } else {
            return nil
        }
    }
}

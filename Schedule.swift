//
//  Schedule.swift
//  SumDU
//
//  Created by Yura on 01.12.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
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

// MARK: - ScheduleRecordDelegate protocol

protocol ScheduleDelegate {
    
// get object of schedule record
    func getRecord()
}

// MARK: - Schedule class

class Schedule {
    
//        protocol deligate
    var delegate: ScheduleDelegate!
    
//            pair data
    var pairTime: String?
    var paitDate: String?
    var pairOrderName: String?
    
//        other data
    var groupName: String?
    var auditoriumName: String?
    var dayOfWeek: String?
    var teacherName: String?
    
//    convert json element to schedule object
    func getRecord(recodrAsJson: JSON) {
//                pair data
        self.pairTime = recodrAsJson[ScheduleResponseParameters.PairTime.rawValue].stringValue
        self.paitDate = recodrAsJson[ScheduleResponseParameters.PairDate.rawValue].stringValue
        self.pairOrderName = recodrAsJson[ScheduleResponseParameters.PairOrderName.rawValue].stringValue
        
//                other data
        self.groupName = recodrAsJson[ScheduleResponseParameters.GroupName.rawValue].stringValue
        self.auditoriumName = recodrAsJson[ScheduleResponseParameters.AuditoriumName.rawValue].stringValue
        self.dayOfWeek = recodrAsJson[ScheduleResponseParameters.DayOfWeek.rawValue].stringValue
        self.teacherName = recodrAsJson[ScheduleResponseParameters.TeacherName.rawValue].stringValue
    }
}

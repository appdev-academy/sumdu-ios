//
//  Schedule.swift
//  SumDU
//
//  Created by Yura on 01.12.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import Foundation
import SwiftyJSON

//    enumeration of all available response parameters
enum scheduleResponseParameters: String {
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
    
//        get object of schedule record
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
        self.pairTime = recodrAsJson[scheduleResponseParameters.PairTime.rawValue].stringValue
        self.paitDate = recodrAsJson[scheduleResponseParameters.PairDate.rawValue].stringValue
        self.pairOrderName = recodrAsJson[scheduleResponseParameters.PairOrderName.rawValue].stringValue
        
//                other data
        self.groupName = recodrAsJson[scheduleResponseParameters.GroupName.rawValue].stringValue
        self.auditoriumName = recodrAsJson[scheduleResponseParameters.AuditoriumName.rawValue].stringValue
        self.dayOfWeek = recodrAsJson[scheduleResponseParameters.DayOfWeek.rawValue].stringValue
        self.teacherName = recodrAsJson[scheduleResponseParameters.TeacherName.rawValue].stringValue
    }
}

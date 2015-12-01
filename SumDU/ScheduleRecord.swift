//
//  ScheduleRecord.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - ScheduleRecordDelegate protocol

protocol ScheduleRecordDelegate {
    
//    get object of schedule record
    func getRecord()
}

// MARK: - ScheduleRecord class

class ScheduleRecord {
    
    //    protocol deligate
    var delegate: ScheduleRecordDelegate!
    
    //        pair data
    var pairTime: String?
    var pairType: String?
    var pairName: String?
    var paitDate: String?
    var pairOrderName: String?
    
    //    other data
    var groupName: String?
    var auditoriumName: String?
    var dayOfWeek: String?
    var teacherName: String?
    
    func getRecord(recodrAsJson: JSON) {
//        TODO: create enum with constants
//        TODO: set data to all vars
        self.pairTime = recodrAsJson["TIME_PAIR"].stringValue
    }
    
}

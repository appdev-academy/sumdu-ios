//
//  Schedule.swift
//  SumDU
//
//  Created by Yura on 01.12.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - ScheduleRecordDelegate protocol

protocol ScheduleDelegate {
    
    //    get object of schedule record
    func getRecords()
}

// MARK: - Schedule class

class Schedule: ScheduleRecordDelegate {
    
    //    protocol deligate
    var delegate: ScheduleDelegate!
    
    var scheduleRecord = ScheduleRecord()
    
    func getRecords(scheduleAsJson: JSON) {
        
        for (_,subJson):(String, JSON) in scheduleAsJson {
            scheduleRecord.getRecord(subJson)
        }
//        TODO: create dictionary with all schedule records and send it to controller
    }
    
    // MARK: - ScheduleRecordDelegate
    func getRecord() {
    }
}

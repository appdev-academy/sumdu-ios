//
//  NavigationController.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import UIKit
import SwiftyJSON

class NavigationController: UINavigationController, ParserDelegate {
    
    /// Object of Parser class
    var parser = Parser()
    
    /// Array of schedule records
    var allRecords: [Schedule] = []
    
    /// Array of all Groups
    var allGroups: [ListData] = []
    
    /// Array of all Teacher's
    var allTeachers: [ListData] = []
    
    /// Array of all lecture halls (objects of Auditory model)
    var allAuditoriums: [ListData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate relation here
        parser.delegate = self
        
        // example of schedule request parametes
        let requestData : [String : String] =
        [
            ScheduleRequestParameter.BeginDate.rawValue: "21.11.2015",
            ScheduleRequestParameter.EndDate.rawValue: "28.11.2015",
            ScheduleRequestParameter.GroupId.rawValue: "100597",
            ScheduleRequestParameter.NameId.rawValue: "0",
            ScheduleRequestParameter.LectureRoomId.rawValue: "0",
            ScheduleRequestParameter.PublicDate.rawValue: "true",
            ScheduleRequestParameter.Param.rawValue: "0"
        ]
        
        // send request with parameters to get records of schedule
        parser.sendScheduleRequest(requestData)
        
        // Auditories request example
        parser.sendDataRequest(.Auditorium)
        
        // Teachers request example
        parser.sendDataRequest(.Teacher)
        
        // Groups request example
        parser.sendDataRequest(.Group)
    }
    
    //    MARK: ParserDelegate
    
    /// Realization of ParserDelegate protocol function for getting schedule data
    func getSchedule(response: JSON) {
        
        if let jsonArray = response.array where jsonArray.count > 0 {
            
            for subJson in jsonArray {
                
                // append schedule object to array of all records
                if let scheduleRecord = Schedule(record: subJson) {
                    allRecords.append(scheduleRecord)
                }
            }
            
            // just for test
//            for record in allRecords {
//                print(record.pairOrderName)
//                print(record.pairTime)
//            }
        }
    }
    
    /// realization of ParserDelegate protocol function for getting related data (teachers, groups and auditorium data)
    func getRelatedData(response: JSON, requestType: ListDataType) {
        
        var recordsToUpdate: [ListData] = []
        
        // Make sure JSON is array and not empty
        if let jsonArray = response.array where jsonArray.count > 0 {
            
            for subJson in jsonArray {
                if let record = ListData(json: subJson, type: requestType) {
                    recordsToUpdate.append(record)
                }
            }
            
            // check request type and create array of objects depending on request type
            switch requestType {
                case .Auditorium:
                    allAuditoriums = recordsToUpdate
                case .Group:
                    allGroups = recordsToUpdate
                case .Teacher:
                    allTeachers = recordsToUpdate
            }
        }
    }
}

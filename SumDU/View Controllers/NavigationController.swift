//
//  NavigationController.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import UIKit
import SwiftyJSON

class NavigationController: UINavigationController, ParserDelegate {
    
    /// Object of Parser class
    var parser = Parser()
    
    /// Array of schedule records
    var allRecords: [Schedule] = []
    
    /// Array of all Groups
    var allGroups: [Group] = []
    
    /// Array of all Teacher's
    var allTeachers: [Teacher] = []
    
    /// Array of all lecture halls (objects of Auditory model)
    var allHalls: [Auditory] = []
    
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
    func getRelatedData(response: JSON, requestType: RelatedDataParameter) {
        
        if let jsonArray = response.array where jsonArray.count > 0 {
            
            // check request type and create array of objects depending on request type
            switch requestType {
                
            // if it Group request - generate array of all available Group's
            case .Group:
                for subJson in jsonArray {
                    
                    if let groupRecord = Group(groupJSON: subJson) {
                        allGroups.append(groupRecord)
                    }
                }
                // test AllGrups array
//                print(allGroups[10].name)
                
            // if it Teachers request - generate array of all available Teacher's
            case .Teacher:
                for subJson in jsonArray {
                    
                    if let teacherRecord = Teacher(teacherJSON: subJson) {
                        allTeachers.append(teacherRecord)
                    }
                }
                // test allTeachers array
//                print(allTeachers[25].name)
                
            // if it Auditorium request - generate array of all available lecture halls
            case .Auditorium:
                for subJson in jsonArray {
                    
                    if let auditoryRecord = Auditory(auditoryJSON: subJson) {
                        allHalls.append(auditoryRecord)
                    }
                }
                // test allHalls array
//                print(allHalls[15].name)
            }
        }
    }
}

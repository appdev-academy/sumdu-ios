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
    
///    Array of schedule records
    var allRecords = [Schedule]()
    
/// Array of all Groups
    var allGroups = [Group]()
    
/// Array of all Teacher's
    var allTeachers = [Teacher]()
    
/// Array of all lecture halls (objects of Auditory model)
    var allHalls = [Auditory]()
    
    override func viewDidLoad() {
        
        //        important line, need explain
        parser.delegate = self
        
        let requestData : [String : String] =
        [
            ScheduleRequestParameters.BeginDate.rawValue: "21.11.2015",
            ScheduleRequestParameters.EndDate.rawValue: "28.11.2015",
            ScheduleRequestParameters.GroupId.rawValue: "100597",
            ScheduleRequestParameters.NameId.rawValue: "0",
            ScheduleRequestParameters.LectureRoomId.rawValue: "0",
            ScheduleRequestParameters.PublicDate.rawValue: "true",
            ScheduleRequestParameters.Param.rawValue: "0"
        ]
        
        parser.sendScheduleRequest(requestData)
        
//        groups request example
        parser.getDataRequest([dataRequestMethod : ScheduleDataParameters.Group.rawValue])
        
        //        teachers request example
        parser.getDataRequest([dataRequestMethod : ScheduleDataParameters.Teachers.rawValue])
        
        //        auditories request example
        parser.getDataRequest([dataRequestMethod : ScheduleDataParameters.Auditorium.rawValue])
    }
    
    //    MARK: ParserDeligate
    
    func getScheduleJson() {
        if parser.jsonResponse.count > 0 {
            
            for (_,subJson):(String, JSON) in parser.jsonResponse {
                
                //                create a new object of schedule model
                let scheduleRecord = Schedule()
                scheduleRecord.getRecord(subJson)
                
                //                append schedule object to array of all records
                allRecords.append(scheduleRecord)
            }
            
            //            just for test
//            for record in allRecords {
//                print(record.pairOrderName)
//                print(record.pairTime)
//            }
        }
    }
    
/// realization of ParserDelegate protocol function
    func getDataResponse(jsonResponse: JSON, requestParameters: [String: String]) {
        if jsonResponse.count > 0 {
            
//            check request type and create array of objects depending on request type
            switch requestParameters[dataRequestMethod]! {
                
//            if it Group request - generate array of all available Group's
            case ScheduleDataParameters.Group.rawValue:
                for (_,subJson):(String, JSON) in jsonResponse {
                    let groupRecord = Group()
                    groupRecord.getGroup(subJson)
                    allGroups.append(groupRecord)
                }
             
//            if it Teachers request - generate array of all available Teacher's
            case ScheduleDataParameters.Teachers.rawValue:
                for (_,subJson):(String, JSON) in jsonResponse {
                    let teacherRecord = Teacher()
                    teacherRecord.getTeacher(subJson)
                    allTeachers.append(teacherRecord)
                }
                
//            if it Auditorium request - generate array of all available lecture halls
            case ScheduleDataParameters.Auditorium.rawValue:
                for (_,subJson):(String, JSON) in jsonResponse {
                    let auditoryRecord = Auditory()
                    auditoryRecord.getAuditory(subJson)
                    allHalls.append(auditoryRecord)
                }

            default: break
            }
        }
    }
}

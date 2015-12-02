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
    
    var parser = Parser()
    
    //    Array of schedule records
    var allRecords = [Schedule]()
    
    override func viewDidLoad() {
        
        //        important line, need explain
        parser.delegate = self
        
        let requestData : [String : String] =
        [
            scheduleRequestParameters.BeginDate.rawValue: "21.11.2015",
            scheduleRequestParameters.EndDate.rawValue: "28.11.2015",
            scheduleRequestParameters.GroupId.rawValue: "100597",
            scheduleRequestParameters.NameId.rawValue: "0",
            scheduleRequestParameters.LectureRoomId.rawValue: "0",
            scheduleRequestParameters.PublicDate.rawValue: "true",
            scheduleRequestParameters.Param.rawValue: "0"
        ]
        
        parser.sendScheduleRequest(requestData)
        
//        groups request example
        parser.getDataRequest([dataRequestMethod : scheduleDataParameters.Group.rawValue])
        
        //        teachers request example
        parser.getDataRequest([dataRequestMethod : scheduleDataParameters.Teachers.rawValue])
        
        //        auditories request example
        parser.getDataRequest([dataRequestMethod : scheduleDataParameters.Auditorium.rawValue])
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
            for record in allRecords {
                print(record.pairOrderName)
                print(record.pairTime)
            }
        }
    }
    
    func getGroupsJson() {
        if parser.dataResult.count > 0 {
            for (_,subJson):(String, JSON) in parser.dataResult {
                print(subJson)
            }
        }
    }
}

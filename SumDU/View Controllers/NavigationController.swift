//
//  NavigationController.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import UIKit
import SwiftyJSON

class NavigationController: UINavigationController, ParserScheduleDelegate {
    
    /// Object of Parser class
    var parser = Parser()
    
    /// Array of schedule records
    var allRecords: [Schedule] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate relation here
        parser.scheduleDelegate = self
        
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
}

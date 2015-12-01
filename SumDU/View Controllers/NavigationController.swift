//
//  NavigationController.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, ParserDelegate, ScheduleDelegate {
    
    var parser = Parser()
    var schedule = Schedule()
    
    override func viewDidLoad() {
        
//        important line, need explain
        parser.deligate = self
        schedule.delegate = self
        
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
        
        parser.sendRequest(requestData)
        
        if parser.resopnseJson.count > 0 {
            schedule.getRecords(parser.resopnseJson)
        }
    }
    
//    MARK: ParserDeligate
    
    func getScheduleJson() {
        if parser.resopnseJson.count > 0 {
            schedule.getRecords(parser.resopnseJson)
        }
    }
    
//    MARK: ScheduleDelegate
    func getRecords() {
    }
}

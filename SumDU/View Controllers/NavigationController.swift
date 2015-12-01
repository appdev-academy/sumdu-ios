//
//  NavigationController.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, ParserDeligate {
    
    var parser = Parser()
    
    override func viewDidLoad() {
        
//        important line, need explain
        self.parser.deligate = self
        
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
        
        self.parser.sendRequest(requestData)
    }
    
//    MARK: ParserDeligate
    
    func getScheduleJson() {
        print(parser.resopnseJson)
    }
}

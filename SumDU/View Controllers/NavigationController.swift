//
//  NavigationController.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        
        let requestData : [String : String] =
        [
            Parameters.BeginDate.rawValue: "21.11.2015",
            Parameters.EndDate.rawValue: "28.11.2015",
            Parameters.GroupId.rawValue: "100597",
            Parameters.NameId.rawValue: "0",
            Parameters.LectureRoomId.rawValue: "0",
            Parameters.PublicDate.rawValue: "true",
            Parameters.Param.rawValue: "0"
        ]
        
        let test = Parser(parameters: requestData)
        test.sendRequest()
//        print(test.resopnseJson)
    }
}

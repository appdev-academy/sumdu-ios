//
//  AppParser.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//    enumeration of all available request parameters
public enum Parameters: String {
    case BeginDate = "data[DATE_BEG]"
    case EndDate = "data[DATE_END]"
    case GroupId = "data[KOD_GROUP]"
    case NameId = "data[ID_FIO]"
    case LectureRoomId = "data[ID_AUD]"
    case PublicDate = "data[PUB_DATE]"
    case Param = "data[PARAM]"
}

// MARK: - Brain Base

public struct Parser {
    
//    URL for requests
    private let scheduleUrl = "http://schedule.sumdu.edu.ua/index/json"
    
//    Dictionary with request parameters
    private var requestParameters :[String : String] = [:]
    
//    Variable for response
//    public var resopnseJson: JSON
    
//    Initialization
    public init(parameters: [String : String]){
        self.requestParameters = parameters
//        self.resopnseJson = []
    }
    
//    function for sending request
    public func sendRequest() {
        
        Alamofire.request(.GET, self.scheduleUrl, parameters: self.requestParameters).responseJSON { (scheduleRequest) -> Void in

            if scheduleRequest.result.isSuccess {
//                if let resultValeu = scheduleRequest.result.value {
////                    self.resopnseJson = JSON(resultValeu)
//                }
            }
            
            if scheduleRequest.result.isFailure {
                print(scheduleRequest.result.error!)
            }
        }
    }
    
    public func testBrain() {
        
        let params : [String : String] =
        [
            Parameters.BeginDate.rawValue: "21.11.2015",
            Parameters.EndDate.rawValue: "28.11.2015",
            Parameters.GroupId.rawValue: "100597",
            Parameters.NameId.rawValue: "0",
            Parameters.LectureRoomId.rawValue: "0",
            Parameters.PublicDate.rawValue: "true",
            Parameters.Param.rawValue: "0"
        ]
        
        Alamofire.request(.GET, "http://schedule.sumdu.edu.ua/index/json", parameters: params).responseJSON { (scheduleRequest) -> Void in
            
            if scheduleRequest.result.isSuccess {
                if let resultValeu = scheduleRequest.result.value {
                    let jsonResult = JSON(resultValeu)
                    print(jsonResult)   
                }
            }
            
            if scheduleRequest.result.isFailure {
                print(scheduleRequest.result.error!)
            }
        }
    }
}
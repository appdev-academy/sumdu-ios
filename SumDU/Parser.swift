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
enum scheduleRequestParameters: String {
    case BeginDate = "data[DATE_BEG]"
    case EndDate = "data[DATE_END]"
    case GroupId = "data[KOD_GROUP]"
    case NameId = "data[ID_FIO]"
    case LectureRoomId = "data[ID_AUD]"
    case PublicDate = "data[PUB_DATE]"
    case Param = "data[PARAM]"
}

// MARK: - Parser protocol

protocol ParserDelegate {
    
    func getScheduleJson()
    
}


// MARK: - Parser class

class Parser {
    
    var deligate: ParserDelegate!
    var resopnseJson:JSON = [:]
    
//    request router
    enum Router: URLRequestConvertible {
        
        static let baseURLString = "http://schedule.sumdu.edu.ua"
        
        case ReadJson([String: AnyObject])
        
        var method: Alamofire.Method {
            switch self {
            case .ReadJson:
                return .POST
            }
        }
        
        var path: String {
            switch self {
            case .ReadJson:
                return "/index/json"
            }
        }
        
        // MARK: URLRequestConvertible
        
        var URLRequest: NSMutableURLRequest {
            let URL = NSURL(string: Router.baseURLString)!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            mutableURLRequest.HTTPMethod = method.rawValue
            
            switch self {
            case .ReadJson(let parameters):
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            }
        }
    }
    
//    function for sending request
    func sendRequest(requestParameters: [String: String]) {
        
        Alamofire.request(Router.ReadJson(requestParameters)).responseJSON { (scheduleRequest) -> Void in
            
            if scheduleRequest.result.isFailure {
                NSLog("Error: \(scheduleRequest.result.error!)")
            }
            
            if scheduleRequest.result.isSuccess {
                if let resultValeu = scheduleRequest.result.value {
                    self.resopnseJson = JSON(resultValeu)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.deligate.getScheduleJson()
                    })
                }
            }
        }
    }
}
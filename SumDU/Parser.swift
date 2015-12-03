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
enum ScheduleRequestParameters: String {
    case BeginDate = "data[DATE_BEG]"
    case EndDate = "data[DATE_END]"
    case GroupId = "data[KOD_GROUP]"
    case NameId = "data[ID_FIO]"
    case LectureRoomId = "data[ID_AUD]"
    case PublicDate = "data[PUB_DATE]"
    case Param = "data[PARAM]"
}

let dataRequestMethod = "method"

// enumeration of available data request types
enum ScheduleDataParameters: String {
    case Group = "getGroups"
    case Auditorium = "getAuditoriums"
    case Teachers = "getTeachers"
}

// MARK: - Parser protocol

protocol ParserDelegate {
    
    func getScheduleJson()
    
    func getDataResponse(jsonResponse: JSON, requestParameters: [String: String])
    
}


// MARK: - Parser class

class Parser {
    
    var delegate: ParserDelegate!
    
    var jsonResponse:JSON = [:]
    var dataResult:JSON = [:]
    
//    request router
    enum Router: URLRequestConvertible {
        
        case ReadJson([String: AnyObject])
        case getDataRequest([String: AnyObject])
                var baseURLString: String {
            switch self {
            case .ReadJson:
                return "http://schedule.sumdu.edu.ua"
            case .getDataRequest:
                return "http://m.schedule.sumdu.edu.ua"
            }
        }
        
        var method: Alamofire.Method {
            switch self {
            case .ReadJson:
                return .POST
            case .getDataRequest:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .ReadJson:
                return "/index/json"
            case .getDataRequest:
                return "/php/index.php"
            }
        }
        
        // MARK: URLRequestConvertible
        
        var URLRequest: NSMutableURLRequest {
            let URL = NSURL(string: baseURLString)!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            mutableURLRequest.HTTPMethod = method.rawValue
            
            switch self {
            case .ReadJson(let parameters):
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            case .getDataRequest(let parameters):
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            }
        }
    }
    
//    function for sending schedule request
    
    func sendScheduleRequest(requestParameters: [String: String]) {
        
        Alamofire.request(Router.ReadJson(requestParameters)).responseJSON { (scheduleRequest) -> Void in
            
            if scheduleRequest.result.isFailure {
                NSLog("Error: \(scheduleRequest.result.error!)")
            }
            
            if scheduleRequest.result.isSuccess {
                if let resultValeu = scheduleRequest.result.value {
                    self.jsonResponse = JSON(resultValeu)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate.getScheduleJson()
                    })
                }
            }
        }
    }
    
//    get data request (groups, teachers, auditories)
    
    func getDataRequest(requestParameters: [String: String]) {
        
        Alamofire.request(Router.getDataRequest(requestParameters)).responseJSON { (gropusRequest) -> Void in
            
            if gropusRequest.result.isFailure {
                NSLog("Error: \(gropusRequest.result.error!)")
            }
            
            if gropusRequest.result.isSuccess {
                if let resultValue = gropusRequest.result.value {
                    
                    let jsonResponse = JSON(resultValue)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate.getDataResponse(jsonResponse, requestParameters: requestParameters)
                    })
                }
            }
        }
    }
}
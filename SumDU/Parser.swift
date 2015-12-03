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
enum ScheduleRequestParameter: String {
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
enum ScheduleDataParameter: String {
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

/// Class that parses responses from server
class Parser {
    
    static let baseURLString        = "http://schedule.sumdu.edu.ua"
    static let mobileBaseURLString  = "http://m.schedule.sumdu.edu.ua"
    
    var delegate: ParserDelegate?
    
    var jsonResponse:JSON = [:]
    var dataResult:JSON = [:]
    
    /// Request router
    enum Router: URLRequestConvertible {
        
        case ReadJson([String: AnyObject])
        case getDataRequest([String: AnyObject])
        
        // Returns base URL for each request
        var baseURLString: String {
            switch self {
                case .ReadJson:
                    return Parser.baseURLString
                case .getDataRequest:
                    return Parser.mobileBaseURLString
            }
        }
        
        // Returns HTTP method for each request
        var method: Alamofire.Method {
            switch self {
                case .ReadJson:
                    return .POST
                case .getDataRequest:
                    return .GET
            }
        }
        
        // Returns relative path to each API endpoint
        var path: String {
            switch self {
                case .ReadJson:
                    return "/index/json"
                case .getDataRequest:
                    return "/php/index.php"
            }
        }
        
        // URLRequestConvertible protocol realization
        var URLRequest: NSMutableURLRequest {
            let URL = NSURL(string: baseURLString)!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            mutableURLRequest.HTTPMethod = method.rawValue
            
            var parameters: [String: AnyObject] = [:]
            switch self {
                case .ReadJson(let params):
                    parameters = params
                case .getDataRequest(let params):
                    parameters = params
            }
            let request = Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            return request
        }
    }
    
//    function for sending schedule request
    
    func sendScheduleRequest(requestParameters: [String: String]) {
        
        Alamofire.request(Router.ReadJson(requestParameters)).responseJSON {
            (scheduleResponse) -> Void in
            
            if scheduleResponse.result.isFailure {
                NSLog("Error: \(scheduleResponse.result.error!)")
            }
            
            if scheduleResponse.result.isSuccess {
                if let resultValue = scheduleResponse.result.value {
                    self.jsonResponse = JSON(resultValue)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate?.getScheduleJson()
                    })
                }
            }
        }
    }
    
//    get data request (groups, teachers, auditories)
    
    func getDataRequest(scheduleDataParameter: ScheduleDataParameter) {
        
        Alamofire.request(Router.getDataRequest(requestParameters)).responseJSON {
            (groupsRequest) -> Void in
            
            if groupsRequest.result.isFailure {
                NSLog("Error: \(groupsRequest.result.error!)")
            }
            
            if groupsRequest.result.isSuccess {
                if let resultValue = groupsRequest.result.value {
                    
                    let jsonResponse = JSON(resultValue)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate?.getDataResponse(jsonResponse, requestParameters: requestParameters)
                    })
                }
            }
        }
    }
}
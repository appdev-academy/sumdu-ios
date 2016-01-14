//
//  AppParser.swift
//  SumDU
//
//  Created by Yura on 28.11.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// Request parameter for schedule
enum ScheduleRequestParameter: String {
    case BeginDate = "data[DATE_BEG]"
    case EndDate = "data[DATE_END]"
    case GroupId = "data[KOD_GROUP]"
    case NameId = "data[ID_FIO]"
    case LectureRoomId = "data[ID_AUD]"
}

/// Request parameter for calendar
enum CalendarRequestParameter: String {
    case BeginDate = "date_beg"
    case EndDate = "date_end"
    case GroupId = "id_grp"
    case NameId = "id_fio"
    case LectureRoomId = "id_aud"
}

/// Type of request
enum RequestType: String {
    case ScheduleRequest = "schedule"
    case CalendarRequest = "calendar"
}

/// Type of ListData entity or request type: Auditorium, Group, Teacher or Unknown
enum ListDataType: String {
    case Auditorium = "getAuditoriums"
    case Group = "getGroups"
    case Teacher = "getTeachers"
}

// MARK: - ParserDelegate protocol

/// Protocol for Parser (returns JSON with schedule)
protocol ParserScheduleDelegate {
    /**
     Required method for schedule request
    
     - parameter response:  result of the schedule request in JSON type
    */
    func getSchedule(response: JSON)
    
    /**
     Required method for calendar request
     
     - parameter url:  generated calendar url
     */
    func getCalendar(url: NSURL?)
}

/// Protocol for Parser (returns JSON for Auditoriums, Groups or Teachers)
protocol ParserDataListDelegate {
    /**
     Required method for mobile request (teachers, groups and auditorium data)
     
     - parameter response:  result of the data request in JSON type
     - parameter requestType:  type of related request
    */
    func getRelatedData(response: JSON, requestType: ListDataType)
}

// MARK: - Parser class

/// Class that parses responses from server
class Parser {
    
    /// Main url for schedule requests
    static let baseURL       = "http://schedule.sumdu.edu.ua"
    
    /// Url of mobile API for data requests (teachers, groups and auditorium)
    static let mobileBaseURL = "http://m.schedule.sumdu.edu.ua"
    
    /// Parser protocol delegates
    var scheduleDelegate: ParserScheduleDelegate?
    var dataListDelegate: ParserDataListDelegate?
    
    /// Request router
    enum Router: URLRequestConvertible {
        
        case ScheduleRequest([String: AnyObject])
        case RelatedDataRequest(relatedDataParameter: ListDataType)
        case ScheduleCalendarRequest([String: AnyObject])
        
        // Returns base URL for each request
        var baseURLString: String {
            switch self {
                case .ScheduleRequest, .ScheduleCalendarRequest:
                    return Parser.baseURL
                case .RelatedDataRequest:
                    return Parser.mobileBaseURL
            }
        }
        
        // Returns HTTP method for each request
        var method: Alamofire.Method {
            switch self {
                case .ScheduleRequest:
                    return .POST
                case .RelatedDataRequest, .ScheduleCalendarRequest:
                    return .GET
            }
        }
        
        // Returns relative path to each API endpoint
        var path: String {
            switch self {
                case .ScheduleRequest:
                    return "/index/json"
                case .RelatedDataRequest:
                    return "/php/index.php"
                case .ScheduleCalendarRequest:
                    return "/index/ical"
            }
        }
        
        // URLRequestConvertible protocol realization
        var URLRequest: NSMutableURLRequest {
            let URL = NSURL(string: baseURLString)!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            mutableURLRequest.HTTPMethod = method.rawValue
            
            var parameters: [String: AnyObject] = [:]
            switch self {
                case .ScheduleRequest(let params):
                    parameters = params
                case .ScheduleCalendarRequest(let params):
                parameters = params
                case .RelatedDataRequest(let relatedDataParameter):
                    parameters = ["method": relatedDataParameter.rawValue]
            }
            let request = Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            return request
        }
    }
    
    /**
     Function for generating request parameter for schedule requests
     
     - parameter requestData:  what parameters need for schedule request
     */
    func getRequestParameters(requestData: ListData?, typeOfRequest: RequestType) -> [String : String] {
        
        // Request data
        var groupId = "0"
        var teacherId = "0"
        var auditoriumId = "0"
        
        // Detect request type
        if let selectedType = requestData?.type, let selectedId = requestData?.id {
            
            let id = String(selectedId)
            
            switch selectedType {
            case ListDataType.Group: groupId = id
            case ListDataType.Teacher: teacherId = id
            case ListDataType.Auditorium: auditoriumId = id
            }
        }
        
        // Get start date
        let startDate = NSDate()
        let dateFormatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = locale
        
        // Get end date
        let additionalDays: NSTimeInterval = 30*60*60*24
        let endDate = startDate.dateByAddingTimeInterval(additionalDays)
        
        var requestData: [String : String]
        
        switch typeOfRequest {
            
            case .CalendarRequest:
            
                // Calendar request parameters
                requestData =
                    [
                        CalendarRequestParameter.BeginDate.rawValue: dateFormatter.stringFromDate(startDate),
                        CalendarRequestParameter.EndDate.rawValue: dateFormatter.stringFromDate(endDate),
                        CalendarRequestParameter.GroupId.rawValue: groupId,
                        CalendarRequestParameter.NameId.rawValue: teacherId,
                        CalendarRequestParameter.LectureRoomId.rawValue: auditoriumId,
                ]
            
            case .ScheduleRequest:
                
                // Schedule request parameters
                requestData =
                    [
                        ScheduleRequestParameter.BeginDate.rawValue: dateFormatter.stringFromDate(startDate),
                        ScheduleRequestParameter.EndDate.rawValue: dateFormatter.stringFromDate(endDate),
                        ScheduleRequestParameter.GroupId.rawValue: groupId,
                        ScheduleRequestParameter.NameId.rawValue: teacherId,
                        ScheduleRequestParameter.LectureRoomId.rawValue: auditoriumId,
                ]
        }
        
        return requestData
    }
    
    /**
     Function for generating schedule URL for calendar
     
     - parameter requestData:  what parameters need for schedule request
     */
    func generateCalendarURL(requestData: ListData?) {
        
        // Get parameters for request
        let dataForRequest = self.getRequestParameters(requestData, typeOfRequest: .CalendarRequest)
        
        // Generate url
        let calendarURL = Router.ScheduleCalendarRequest(dataForRequest).URLRequest.URL
        
        // Call delegate function
        self.scheduleDelegate?.getCalendar(calendarURL)
    }
    
    /**
     Function for sending schedule request
     
     - parameter requestData:  what parameters need for schedule request
     */
    func sendScheduleRequest(requestData: ListData?) {
        
        // Get data for request
        let dataForRequest = self.getRequestParameters(requestData, typeOfRequest: .ScheduleRequest)
        
        // Send request
        Alamofire.request(Router.ScheduleRequest(dataForRequest)).responseJSON {
            (scheduleResponse) -> Void in
            
            if scheduleResponse.result.isFailure {
                NSLog("Error: \(scheduleResponse.result.error!)")
            }
            
            if scheduleResponse.result.isSuccess {
                if let resultValue = scheduleResponse.result.value {
                    let response = JSON(resultValue)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.scheduleDelegate?.getSchedule(response)
                    })
                }
            }
        }
    }
    
    /**
     Send request for related data (groups, teachers, auditories)
     
     - parameter withParameter:  type of related request
     */
    func sendDataRequest(relatedDataParameter: ListDataType) {
        Alamofire.request(Router.RelatedDataRequest(relatedDataParameter: relatedDataParameter)).responseJSON {
            (groupsRequest) -> Void in
            
            if groupsRequest.result.isFailure {
                NSLog("Error: \(groupsRequest.result.error!)")
            }
            
            if groupsRequest.result.isSuccess {
                if let resultValue = groupsRequest.result.value {
                    
                    let response = JSON(resultValue)
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(NSDate(), forKey: keyLastUpdatedAtDate)
                    defaults.synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dataListDelegate?.getRelatedData(response, requestType: relatedDataParameter)
                    })
                }
            }
        }
    }
}
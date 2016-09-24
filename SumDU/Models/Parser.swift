//
//  AppParser.swift
//  SumDU
//
//  Created by Yura Voevodin on 28.11.15.
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
    func getSchedule(_ response: JSON)
    
    /**
        Required method for calendar request
     
        - parameter url:  generated calendar url
    */
    func getCalendar(_ url: URL?)
    
    /**
        Return error string if request fails
     
        - parameter parser: Entity of parser
        - parameter localizedError: Error string
     */
    func scheduleRequestError(_ parser: Parser, localizedError error: String?)
}

/// Protocol for Parser (returns JSON for Auditoriums, Groups or Teachers)
protocol ParserDataListDelegate {
    /**
        Required method for mobile request (teachers, groups and auditorium data)
     
        - parameter response:  result of the data request in JSON type
        - parameter requestType:  type of related request
    */
    func getRelatedData(_ response: JSON, requestType: ListDataType)
    
    /**
        Return error string if request fails
     
        - parameter parser: Entity of parser
        - parameter localizedError: Error string
    */
    func requestError(_ parser: Parser, localizedError error: String?)
}

// MARK: - Parser class

/// Class that parses responses from server
class Parser {
    
    // MARK: - Variables
    
    /// Parser protocol delegates
    var scheduleDelegate: ParserScheduleDelegate?
    var dataListDelegate: ParserDataListDelegate?
    
    var scheduleRequest: Request?
    
    /// Request router
    enum Router: URLRequestConvertible {
        
        case scheduleRequest([String: String])
        case relatedDataRequest(relatedDataParameter: ListDataType)
        case scheduleCalendarRequest([String: String])
        
        /// Main URL for schedule requests
        static let baseURL = "http://schedule.sumdu.edu.ua"
        
        /// URL of mobile API for data requests (teachers, groups and auditorium)
        static let mobileBaseURL = "http://m.schedule.sumdu.edu.ua"
        
        // Returns base URL for each request
        var baseURLString: String {
            switch self {
            case .scheduleRequest, .scheduleCalendarRequest:
                return Router.baseURL
            case .relatedDataRequest:
                return Router.mobileBaseURL
            }
        }
        
        /// Returns HTTP method for each request
        var method: HTTPMethod {
            switch self {
            case .scheduleRequest:
                return .post
            case .relatedDataRequest, .scheduleCalendarRequest:
                return .get
            }
        }
        
        /// Returns relative path to each API endpoint
        var path: String {
            switch self {
            case .scheduleRequest:
                return "/index/json"
            case .relatedDataRequest:
                return "/php/index.php"
            case .scheduleCalendarRequest:
                return "/index/ical"
            }
        }
        
         // MARK: - URLRequestConvertible
        
        func asURLRequest() throws -> URLRequest {
            let url = try baseURLString.asURL()
            
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            
            switch self {
            case .scheduleRequest(let params):
                urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
                
            case .scheduleCalendarRequest(let params):
                urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
                
            case .relatedDataRequest(let params):
                let parameters: [String: AnyObject] = ["method": params.rawValue as AnyObject]
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            }
            return urlRequest
        }
    }
    
    /**
        Function for generating request parameter for schedule requests
     
        - parameter requestData:  what parameters need for schedule request
    */
    func getRequestParameters(_ requestData: ListData?, typeOfRequest: RequestType) -> [String : String] {
        
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
        let startDate = Date()
        let dateFormatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = locale
        
        // Get end date
        let additionalDays: TimeInterval = 30*60*60*24
        let endDate = startDate.addingTimeInterval(additionalDays)
        
        var requestData: [String : String]
        
        switch typeOfRequest {
            
        case .CalendarRequest:
            // Calendar request parameters
            requestData = [
                CalendarRequestParameter.BeginDate.rawValue: dateFormatter.string(from: startDate),
                CalendarRequestParameter.EndDate.rawValue: dateFormatter.string(from: endDate),
                CalendarRequestParameter.GroupId.rawValue: groupId,
                CalendarRequestParameter.NameId.rawValue: teacherId,
                CalendarRequestParameter.LectureRoomId.rawValue: auditoriumId,
            ]
        case .ScheduleRequest:
            // Schedule request parameters
            requestData = [
                ScheduleRequestParameter.BeginDate.rawValue: dateFormatter.string(from: startDate),
                ScheduleRequestParameter.EndDate.rawValue: dateFormatter.string(from: endDate),
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
    func generateCalendarURL(_ requestData: ListData?) {
        
        // Get parameters for request
        let dataForRequest = getRequestParameters(requestData, typeOfRequest: .CalendarRequest)

        // Generate url
        let calendarURL = Router.scheduleCalendarRequest(dataForRequest).urlRequest?.url

        // Call delegate function
        scheduleDelegate?.getCalendar(calendarURL)
    }
    
    /**
        Function for sending schedule request
     
        - parameter requestData: what parameters need for schedule request
    */
    func sendScheduleRequest(_ requestData: ListData?) {
        
        // Get data for request
        let dataForRequest = getRequestParameters(requestData, typeOfRequest: .ScheduleRequest)

        // Send request
       scheduleRequest = Alamofire.request(Router.scheduleRequest(dataForRequest)).responseJSON {
            response in
            
            if response.result.isSuccess, let resultValue = response.result.value {
                let response = JSON(resultValue)
                self.scheduleDelegate?.getSchedule(response)
            } else {
                self.scheduleDelegate?.scheduleRequestError(self, localizedError: response.result.error?.localizedDescription)
            }
        }
    }
    
    /**
        Send request for related data (groups, teachers, auditories)
     
        - parameter withParameter: type of related request
    */
    func sendDataRequest(_ relatedDataParameter: ListDataType) {
        
        Alamofire.request(Router.relatedDataRequest(relatedDataParameter: relatedDataParameter)).responseJSON { (response) in
            
            if response.result.isSuccess, let resultValue = response.result.value {
                // Save last update date
                UserDefaults.standard.set(Date(), forKey: UserDefaultsKey.LastUpdatedAtDate.key)
                let response = JSON(resultValue)
                // Call delegate method
                self.dataListDelegate?.getRelatedData(response, requestType: relatedDataParameter)
            } else {
                self.dataListDelegate?.requestError(self, localizedError: response.result.error?.localizedDescription)
            }
        }
    }
}

//
//  AppParser.swift
//  SumDU
//
//  Created by Yura Voevodin on 28.11.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import Alamofire
import Foundation
import Fuzi
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
  case Auditorium = "auditorium"
  case Group = "group"
  case Teacher = "teacher"
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
  /// Delegate for fetching Auditoriums, Groups and Teachers
  ///
  /// - Parameters:
  ///   - response: result of the data request in JSON type
  ///   - requestType: type of related request
  /// <#Description#>
  ///
  /// - Parameters:
  ///   - auditoriums: array of ListData objects with type 'Auditoriums' 
  ///   - groups: <#groups description#>
  ///   - teachers: <#teachers description#>
  func requesSuccess(auditoriums: [ListData], groups: [ListData], teachers: [ListData])
  
  /**
   Return error string if request fails
   
   - parameter parser: Entity of parser
   - parameter localizedError: Error string
   */
  func requestError(_ parser: Parser, localizedError error: String?)
}

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
    case scheduleCalendarRequest([String: String])
    case updateListsOfAuditoriumsGroupsTeachers()
    
    /// Main URL for schedule requests
    static let baseURL = "http://schedule.sumdu.edu.ua"
    
    /// Returns HTTP method for each request
    var method: HTTPMethod {
      switch self {
      case .scheduleRequest:
        return .post
      case .scheduleCalendarRequest:
        return .get
      case .updateListsOfAuditoriumsGroupsTeachers:
        return .get
      }
    }
    
    /// Returns relative path to each API endpoint
    var path: String {
      switch self {
      case .scheduleRequest:
        return "/index/json"
      case .scheduleCalendarRequest:
        return "/index/ical"
      case .updateListsOfAuditoriumsGroupsTeachers:
        return ""
      }
    }
    
    // MARK: - URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
      let url = try Router.baseURL.asURL()
      
      var urlRequest = URLRequest(url: url.appendingPathComponent(path))
      urlRequest.httpMethod = method.rawValue
      
      switch self {
      case .scheduleRequest(let params):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
      case .scheduleCalendarRequest(let params):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
      case .updateListsOfAuditoriumsGroupsTeachers():
        urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
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
  
  /// Function for generating schedule URL for calendar
  ///
  /// - parameter requestData: parameters for schedule request
  func generateCalendarURL(_ requestData: ListData?) {
    
    // Get parameters for request
    let dataForRequest = getRequestParameters(requestData, typeOfRequest: .CalendarRequest)
    
    // Generate url
    let calendarURL = Router.scheduleCalendarRequest(dataForRequest).urlRequest?.url
    
    // Call delegate function
    scheduleDelegate?.getCalendar(calendarURL)
  }
  
  /// Send schedule request
  ///
  /// - Parameter requestData: ListData to create schedule request for
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
  
  /// Update and save Auditoriums, Groups and Teachers from server
  func updateListsOfAuditoriumsGroupsAndTeachers() {
    
    Alamofire.request(Router.updateListsOfAuditoriumsGroupsTeachers()).responseString {
      response in
      
      let htmlString = response.description
      
      do {
        let htmlDocument = try HTMLDocument(string: htmlString, encoding: String.Encoding.windowsCP1251)
        
        var auditoriums: [ListData] = []
        var groups: [ListData] = []
        var teachers: [ListData] = []
        
        // Auditoriums
        if let auditoriumsSelect = htmlDocument.firstChild(css: "#auditorium") {
          for option in auditoriumsSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              let auditorium = ListData(id: id, name: option.stringValue, type: ListDataType.Auditorium)
              auditoriums.append(auditorium)
            }
          }
        }
        
        // Groups
        if let groupsSelect = htmlDocument.firstChild(css: "#group") {
          for option in groupsSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              let group = ListData(id: id, name: option.stringValue, type: ListDataType.Group)
              groups.append(group)
            }
          }
        }
        
        // Teachers
        if let teachersSelect = htmlDocument.firstChild(css: "#teacher") {
          for option in teachersSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              let teacher = ListData(id: id, name: option.stringValue, type: ListDataType.Teacher)
              teachers.append(teacher)
            }
          }
        }
        
        self.dataListDelegate?.requesSuccess(auditoriums: auditoriums, groups: groups, teachers: teachers)
        
      } catch {
        self.dataListDelegate?.requestError(self, localizedError: NSLocalizedString("Error while importing Auditoriums, Groups and Teachers", comment: "Error message"))
      }
    }
  }
}

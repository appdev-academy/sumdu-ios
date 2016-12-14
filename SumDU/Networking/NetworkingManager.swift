//
//  NetworkingManager.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Alamofire
import CoreDuck
import Foundation
import Fuzi

/// Type of content to display
enum ContentType: Int {
  
  case history = 0
  case groups = 1
  case teachers = 2
  case auditoriums = 3
  
  var name: String {
    switch self {
    case .history:
      return ""
    case .groups:
      return NSLocalizedString("Group", comment: "")
    case .teachers:
      return NSLocalizedString("Teacher", comment: "")
    case .auditoriums:
      return NSLocalizedString("Auditorium", comment: "")
    }
  }
}

/// Request parameter for schedule
enum ScheduleRequestParameter: String {
  case beginDate = "data[DATE_BEG]"
  case endDate = "data[DATE_END]"
  case groupId = "data[KOD_GROUP]"
  case nameId = "data[ID_FIO]"
  case lectureRoomId = "data[ID_AUD]"
}

/// Request parameter for calendar
enum CalendarRequestParameter: String {
  case beginDate = "date_beg"
  case endDate = "date_end"
  case groupId = "id_grp"
  case nameId = "id_fio"
  case lectureRoomId = "id_aud"
}

/// Type of request
enum RequestType: String {
  case scheduleRequest = "schedule"
  case calendarRequest = "calendar"
}

/// Notify delegate about result of request
protocol NetworkingManagerDelegate {
  
  func requestStarted()
  
  func requestSucceed()
  
  func requestFailed()
}

/// For network requests
class NetworkingManager {
  
  // MARK: - Variables
  
  var delegate: NetworkingManagerDelegate?
  
  // MARK: - Public interface
  
  /// Update Auditoriums, Groups and Teachers from server
  static func updateListsOfAuditoriumsGroupsAndTeachers() {
    
    Alamofire.request(Router.updateListsOfAuditoriumsGroupsTeachers).responseString {
      response in
      
      let htmlString = response.description
      
      do {
        let htmlDocument = try HTMLDocument(string: htmlString, encoding: String.Encoding.windowsCP1251)
        var data: [Any] = []
        
        // Auditoriums
        if let auditoriumsSelect = htmlDocument.firstChild(css: "#auditorium") {
          for option in auditoriumsSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              data.append(["name" : option.stringValue, "id" : id, "type": ContentType.auditoriums.rawValue])
            }
          }
        }
        
        // Groups
        if let groupsSelect = htmlDocument.firstChild(css: "#group") {
          for option in groupsSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              data.append(["name" : option.stringValue, "id" : id, "type": ContentType.groups.rawValue])
            }
          }
        }
        
        // Teachers
        if let teachersSelect = htmlDocument.firstChild(css: "#teacher") {
          for option in teachersSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              data.append(["name" : option.stringValue, "id" : id, "type": ContentType.teachers.rawValue])
            }
          }
        }
        
        // Import Auditoriums, Groups and Teachers
        let auditoriumsImportManager = ImportManager<ListObject>()
        auditoriumsImportManager.fromJSON(data, mappedAttributes: ListObject.mappedAttributes)
        
        // Save date of last update
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKey.LastUpdatedAtDate.key)
        
      } catch {
        
        let title = NSLocalizedString("Update error", comment: "Alert title")
        let message = NSLocalizedString("Error while importing Auditoriums, Groups and Teachers", comment: "Alert message")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addOkButton()
        
        // Present alert
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
      }
    }
  }
  
  /// Send schedule request
  ///
  /// - Parameter listObject: Object of whom receive schedule
  func scheduleRequest(for listObject: ListObject) {
    delegate?.requestStarted()
    
    // Get data for request
    let dataForRequest = self.requestParameters(for: listObject, typeOfRequest: RequestType.scheduleRequest)
    
    // Send request
    Alamofire.request(Router.schedule(dataForRequest)).responseJSON {
      response in
      
      switch response.result {
      case .success(let value):
        if let data = value as? [Any] {
          ScheduleImportManager().fromJSON(data, for: listObject)
        }
        self.delegate?.requestSucceed()
        
      case .failure(let error):
        self.delegate?.requestFailed()
        
        let title = NSLocalizedString("Request failed", comment: "Alert title")
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addOkButton()
        
        // Present alert
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
      }
    }
  }
  
  /// Generating schedule URL for calendar
  ///
  /// - Parameter listObject: Object of whom receive calendar
  static func calendarRequest(for listObject: ListObject) -> URL? {
    
    // Get data for request
    let dataForRequest = NetworkingManager().requestParameters(for: listObject, typeOfRequest: RequestType.calendarRequest)
    
    // Generate url
    return Router.scheduleCalendar(dataForRequest).urlRequest?.url
  }
  
  // MARK: - Helpers
  
  /// Generating request parameter for schedule or calendar requests
  ///
  /// - Parameters:
  ///   - listObject: The object is to generate request
  ///   - typeOfRequest: Type of request - schedule or calendar
  /// - Returns: array of parameters
  fileprivate func requestParameters(for listObject: ListObject, typeOfRequest: RequestType) -> [String: String] {
    var requestData: [String : String]
    
    var groupId = "0"
    var teacherId = "0"
    var auditoriumId = "0"
    
    // Request type
    guard let type = ContentType(rawValue: Int(listObject.type)) else { return [:] }
    let id = String(listObject.id)
    
    switch type {
    case .auditoriums:
      auditoriumId = id
    case .groups:
      groupId = id
    case .teachers:
      teacherId = id
    case .history:
      break
    }
    
    // Start and end dates
    let startDate = Date()
    let endDate = startDate.plusOneMonth
    
    switch typeOfRequest {
      
    case .calendarRequest:
      // Calendar request parameters
      requestData = [
        CalendarRequestParameter.beginDate.rawValue: startDate.serverDateFormat,
        CalendarRequestParameter.endDate.rawValue: endDate.serverDateFormat,
        CalendarRequestParameter.groupId.rawValue: groupId,
        CalendarRequestParameter.nameId.rawValue: teacherId,
        CalendarRequestParameter.lectureRoomId.rawValue: auditoriumId,
      ]
    case .scheduleRequest:
      // Schedule request parameters
      requestData = [
        ScheduleRequestParameter.beginDate.rawValue: startDate.serverDateFormat,
        ScheduleRequestParameter.endDate.rawValue: endDate.serverDateFormat,
        ScheduleRequestParameter.groupId.rawValue: groupId,
        ScheduleRequestParameter.nameId.rawValue: teacherId,
        ScheduleRequestParameter.lectureRoomId.rawValue: auditoriumId,
      ]
    }
    return requestData
  }
  
}

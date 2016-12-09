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

/// For network requests
struct NetworkingManager {
  
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
  
}

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

/// For network requests
struct NetworkingManager {
  
  /// Update and save Auditoriums, Groups and Teachers from server
  static func updateListsOfAuditoriumsGroupsAndTeachers() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    Alamofire.request(Router.updateListsOfAuditoriumsGroupsTeachers).responseString {
      response in
      
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      
      let htmlString = response.description
      
      do {
        let htmlDocument = try HTMLDocument(string: htmlString, encoding: String.Encoding.windowsCP1251)
        
        var auditoriums: [Any] = []
        var groups: [Any] = []
        var teachers: [Any] = []
        
        // Auditoriums
        if let auditoriumsSelect = htmlDocument.firstChild(css: "#auditorium") {
          for option in auditoriumsSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              auditoriums.append(["name" : option.stringValue, "id" : id])
            }
          }
        }
        
        // Groups
        if let groupsSelect = htmlDocument.firstChild(css: "#group") {
          for option in groupsSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              groups.append(["name" : option.stringValue, "id" : id])
            }
          }
        }
        
        // Teachers
        if let teachersSelect = htmlDocument.firstChild(css: "#teacher") {
          for option in teachersSelect.children {
            if let idString = option.attr("value"), let id = Int(idString), option.stringValue.characters.count > 1 {
              teachers.append(["name" : option.stringValue, "id" : id])
            }
          }
        }
        
        // Import Auditoriums
        let auditoriumsImportManager = ImportManager<Auditorium>()
        auditoriumsImportManager.fromJSON(auditoriums, mappedAttributes: Auditorium.mappedAttributes)
        
        // Import Groups
        let groupsImportManager = ImportManager<Group>()
        groupsImportManager.fromJSON(groups, mappedAttributes: Group.mappedAttributes)
        
        // Import Teachers
        let teachersImportManager = ImportManager<Teacher>()
        teachersImportManager.fromJSON(teachers, mappedAttributes: Teacher.mappedAttributes)
        
        // Save date of last update
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKey.LastUpdatedAtDate.key)
        
      } catch {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
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

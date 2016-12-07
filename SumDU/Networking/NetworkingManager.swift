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
class NetworkingManager {
  
  /// Update and save Auditoriums, Groups and Teachers from server
  func updateListsOfAuditoriumsGroupsAndTeachers() {
    
    Alamofire.request(Router.updateListsOfAuditoriumsGroupsTeachers).responseString {
      response in
      
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
        auditoriumsImportManager.delegate = self
        auditoriumsImportManager.fromJSON(auditoriums, mappedAttributes: Auditorium.mappedAttributes)
        
        // Import Groups
        let groupsImportManager = ImportManager<Group>()
        groupsImportManager.delegate = self
        groupsImportManager.fromJSON(groups, mappedAttributes: Group.mappedAttributes)
        
        // Import Teachers
        let teachersImportManager = ImportManager<Teacher>()
        teachersImportManager.delegate = self
        teachersImportManager.fromJSON(groups, mappedAttributes: Teacher.mappedAttributes)
        
      } catch {
        
        // TODO: Show error
      }
    }
  }
  
}


// MARK: - ImportManagerDelegate

extension NetworkingManager: ImportManagerDelegate {
  
  func didFailImport() {
    // TODO: Show error
    // TODO: Check error
  }
  
  func didFinishImport() {
    
  }
}

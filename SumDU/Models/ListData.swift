//
//  ListData.swift
//  SumDU
//
//  Created by Maksym Skliarov on 12/10/15.
//  Copyright © 2015 App Dev Academy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Representaion of single record for Auditorium, Group or Teacher
struct ListData {
  
  /// Enumeration of available values in JSON response
  enum ResponseLabel: String {
    case Label = "label"
    case Value = "value"
  }
  
  // MARK: - Constants
  
  /// Server ID for instance
  let id: Int
  
  /// Name of the Auditorium, Group or Teacher
  let name: String
  
  /// ListData type
  let type: ListDataType
  
  // MARK: - Variables
  
  var listDataCoder: ListDataCoder {
    get {
      return ListDataCoder(listData: self)
    }
  }
  
  // MARK: - Lifecycle
  
  /// Initializer for ListData entity
  init?(json: JSON, type: ListDataType) {
    
    if let id = json[ResponseLabel.Value.rawValue].int {
      self.id = id
    } else {
      return nil
    }
    
    if let name = json[ResponseLabel.Label.rawValue].string, name.characters.count > 0 {
      self.name = name
    } else {
      return nil
    }
    
    self.type = type
  }
  
  /// Initializer with all required parameters
  init(id: Int, name: String, type: ListDataType) {
    self.id = id
    self.name = name
    self.type = type
  }
}

// MARK: - Persistency interface

extension ListData {
  
  /// Function which loads ListData entities from NSUserDefaults class
  static func loadFromStorage(_ forKey: String) -> [ListData] {
    var listDataRecords: [ListData] = []
    
    let userDefaults = UserDefaults.standard
    if let listDataCoder = userDefaults.data(forKey: forKey), let listDataArray = NSKeyedUnarchiver.unarchiveObject(with: listDataCoder) as? [ListDataCoder] {
      
      for listDataStruct in listDataArray {
        if let listData = listDataStruct.listData {
          listDataRecords.append(listData)
        }
      }
    }
    return listDataRecords
  }
  
  /// Function which stores ListData entities using NSUserDefaults class
  static func saveToStorage(_ listDataObject: [ListData], forKey: String) {
    var listDataCoders: [ListDataCoder] = []
    for listDataRecord in listDataObject {
      listDataCoders.append(listDataRecord.listDataCoder)
    }
    let userDefaults = UserDefaults.standard
    let data = NSKeyedArchiver.archivedData(withRootObject: listDataCoders)
    userDefaults.set(data, forKey: forKey)
  }
  
  /// Get ListData objects from JSON with ListDataType
  static func from(json response: JSON, type requestType: ListDataType) -> [ListData] {
    var result: [ListData] = []
    if let jsonArray = response.array {
      for subJson in jsonArray {
        if let record = ListData(json: subJson, type: requestType) {
          result.append(record)
        }
      }
    }
    let sortedRecords = result.sorted {$0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending}
    return sortedRecords
  }
  
  /// Function which stores ListData entity
  static func saveObject(_ listDataObject: ListData?, forKey: String) {
    var listDataCoders: [ListDataCoder] = []
    if let lisData = listDataObject {
      listDataCoders.append(lisData.listDataCoder)
      let userDefaults = UserDefaults.standard
      let data = NSKeyedArchiver.archivedData(withRootObject: listDataCoders)
      userDefaults.set(data, forKey: forKey)
    }
  }
  
  /// Function which loads ListData entity
  static func loadObject(_ forKey: String) -> ListData? {
    var listDataRecord: ListData?
    
    let userDefaults = UserDefaults.standard
    if let listDataCoder = userDefaults.data(forKey: forKey) {
      
      if let listData = NSKeyedUnarchiver.unarchiveObject(with: listDataCoder) as? ListDataCoder {
        listDataRecord = listData.listData!
        return listDataRecord
      }
    }
    return listDataRecord
  }
}

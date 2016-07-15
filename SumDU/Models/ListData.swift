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
    
    /// Server ID for instance
    let id: Int
    
    /// Name of the Auditorium, Group or Teacher
    let name: String
    
    /// ListData type
    let type: ListDataType
    
    var listDataCoder: ListDataCoder {
        get {
            return ListDataCoder(listData: self)
        }
    }
    
    /// Initializer for ListData entity
    init?(json: JSON, type: ListDataType) {
        
        if let id = json[ResponseLabel.Value.rawValue].int {
            self.id = id
        } else {
            return nil
        }
        
        if let name = json[ResponseLabel.Label.rawValue].string where name.characters.count > 0 {
            self.name = name
        } else {
            return nil
        }
        
        self.type = type
    }
    
    /// Initializer which is used for ListDAtaCoder class
    init(id: Int, name: String, type: ListDataType) {
        self.id = id
        self.name = name
        self.type = type
    }
}

extension ListData {
    
    /// Function which loads ListData entities from NSUserDefaults class
    static func loadFromStorage(forKey: String) -> [ListData] {
        var listDataRecords: [ListData] = []
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let listDataCoder = userDefaults.dataForKey(forKey), listDataArray = NSKeyedUnarchiver.unarchiveObjectWithData(listDataCoder) as? [ListDataCoder] {
            
            for listDataStruct in listDataArray {
                if let listData = listDataStruct.listData {
                    listDataRecords.append(listData)
                }
            }
        }
        return listDataRecords
    }
    
    /// Function which stores ListData entities using NSUserDefaults class
    static func saveToStorage(listDataObject: [ListData], forKey: String) {
        var listDataCoders: [ListDataCoder] = []
        for listDataRecord in listDataObject {
            listDataCoders.append(listDataRecord.listDataCoder)
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(listDataCoders)
        userDefaults.setObject(data, forKey: forKey)
        
        // TODO: Don't use synchronize?
        userDefaults.synchronize()
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
        let sortedRecords = result.sort {$0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending}
        return sortedRecords
    }
    
    /// Function which stores ListData entity
    static func saveObject(listDataObject: ListData?, forKey: String) {
        var listDataCoders: [ListDataCoder] = []
        if let lisData = listDataObject {
            listDataCoders.append(lisData.listDataCoder)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let data = NSKeyedArchiver.archivedDataWithRootObject(listDataCoders)
            userDefaults.setObject(data, forKey: forKey)
            userDefaults.synchronize()
        }
    }
    
    /// Function which loads ListData entity
    static func loadObject(forKey: String) -> ListData? {
        var listDataRecord: ListData?
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let listDataCoder = userDefaults.dataForKey(forKey) {
            
            if let listData = NSKeyedUnarchiver.unarchiveObjectWithData(listDataCoder) as? ListDataCoder {
                listDataRecord = listData.listData!
                return listDataRecord
            }
        }
        return listDataRecord
    }
}

extension ListData: Equatable {}

    func ==(lhs: ListData, rhs:ListData) -> Bool {
        return lhs.name == rhs.name
    }
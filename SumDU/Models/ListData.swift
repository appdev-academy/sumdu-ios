//
//  ListData.swift
//  SumDU
//
//  Created by Maksym Skliarov on 12/10/15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
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

    
    /// Initializer for ListData entity
    init?(json: JSON, type: ListDataType) {
        
        if let id = json[ResponseLabel.Value.rawValue].int {
            self.id = id
        } else {
            return nil
        }
        
        if let name = json[ResponseLabel.Label.rawValue].string {
            self.name = name
        } else {
            return nil
        }
       
        //DataProcessing(id: id, name: name)
        
        self.type = type
    }
    
    static func encode(json: JSON, type: ListDataType) {
        let dataProcessingClassObject = ListData(json: json, type: type)
        //NSKeyedArchiver.archiveRootObject(dataProcessingClassObject as ListData?, toFile: DataProcessing.path())
        let data = NSKeyedArchiver.archivedDataWithRootObject(dataProcessingClassObject)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "student")
    }
    
    static func decode() -> ListData? {
        let dataProcessingClassObject = NSKeyedUnarchiver.unarchiveObjectWithFile(DataProcessing.path()) as? ListData
        
        return dataProcessingClassObject
    }
}
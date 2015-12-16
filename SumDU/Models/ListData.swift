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
        
        if let name = json[ResponseLabel.Label.rawValue].string {
            self.name = name
        } else {
            return nil
        }
        
        self.type = type
    }
    
    init(id: Int, name: String, type: ListDataType) {
        self.id = id
        self.name = name
        self.type = type
    }
}
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
    
    /// Type of ListData entity: Auditorium, Group, Teacher or Unknown
    enum ListDataType {
        case Auditorium
        case Group
        case Teacher
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
        
        self.type = type
    }
}
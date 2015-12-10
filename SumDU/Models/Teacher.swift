//
//  Teacher.swift
//  SumDU
//
//  Created by Yura on 03.12.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Enumeration of available values in JSON response of teachers request
enum TeacherResponseLable: String {
    case Label = "label"
    case Value = "value"
}

// MARK: - Teacher struct (single record about teacher)

struct Teacher {
    
    /// Name of teacher
    let name: String
    
    /// Id of teacher
    let id: Int
    
    /**
     Initializer for teacher struct
     
     - parameter teacherJSON:  JSON type parameter with single teacher record
     */
    init?(teacherJSON: JSON) {
        
        if let name = teacherJSON[TeacherResponseLable.Label.rawValue].string {
            self.name = name
        } else {
            return nil
        }
        
        if let id = teacherJSON[TeacherResponseLable.Value.rawValue].int {
            self.id = id
        } else {
            return nil
        }
    }
}
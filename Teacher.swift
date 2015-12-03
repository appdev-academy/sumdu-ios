//
//  Teacher.swift
//  SumDU
//
//  Created by Yura on 03.12.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Enumeration of available values in JSON response of teachers request
enum TeacherResponseLables: String {
    case Label = "label"
    case Value = "value"
}

// MARK: - TeacherDelegate protocol
protocol TeacherDelegate {
    
/// Returns object of Teacher model
    func getTeacher(teacherAsJson: JSON)
}

// MARK: - Teacher class
class Teacher {
    
/// Name of teacher
    var label: String?
    
/// Id of teacher
    var value: Int?
    
/// Get Teacher object from JSON data
    func getTeacher(teacherAsJson: JSON) {
        label = teacherAsJson[TeacherResponseLables.Label.rawValue].stringValue
        value = teacherAsJson[TeacherResponseLables.Value.rawValue].intValue
    }
}
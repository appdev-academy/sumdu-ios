//
//  Auditory.swift
//  SumDU
//
//  Created by Yura on 03.12.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Enumeration of available values in JSON response of auditories request
enum AuditoryResponseLables: String {
    case Label = "label"
    case Value = "value"
}

// MARK: - AuditoryDelegate protocol
protocol AuditoryDelegate {
    
/// Returns object of Auditory model
    func getAuditory(auditoryAsJson: JSON)
}

// MARK: - Auditory class
class Auditory {
    
/// Name of auditory
    var label: String?
    
/// Id of auditory
    var value: Int?
    
/// Get Teacher object from JSON data
    func getAuditory(auditoryAsJson: JSON) {
        label = auditoryAsJson[TeacherResponseLables.Label.rawValue].stringValue
        value = auditoryAsJson[TeacherResponseLables.Value.rawValue].intValue
    }
}
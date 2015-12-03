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
    var label: String
    
    /// Id of auditory
    var value: Int
    
    init?(auditoryJSON: JSON) {
        // Set default values (probably bug in Xcode, can't return nil on failable initializer)
        self.label = ""
        self.value = 1
        
        if let label = auditoryJSON[TeacherResponseLables.Label.rawValue].string {
            self.label = label
        } else {
            return nil
        }
        
        if let value = auditoryJSON[TeacherResponseLables.Value.rawValue].int {
            self.value = value
        } else {
            return nil
        }
    }
}
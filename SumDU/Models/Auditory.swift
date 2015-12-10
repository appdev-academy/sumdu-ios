//
//  Auditory.swift
//  SumDU
//
//  Created by Yura on 03.12.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Enumeration of available values in JSON response of auditories request
enum AuditoryResponseLable: String {
    case Label = "label"
    case Value = "value"
}

// MARK: - Auditory struct (single record about auditory)

struct Auditory {
    
    /// Name of auditory
    let name: String
    
    /// Id of auditory
    let id: Int
    
    /**
     Initializer for auditory struct
     
     - parameter auditoryJSON:  JSON type parameter with single auditory record
     */
    init?(auditoryJSON: JSON) {
        
        if let name = auditoryJSON[AuditoryResponseLable.Label.rawValue].string {
            self.name = name
        } else {
            return nil
        }
        
        if let id = auditoryJSON[AuditoryResponseLable.Value.rawValue].int {
            self.id = id
        } else {
            return nil
        }
    }
}
//
//  Group.swift
//  SumDU
//
//  Created by Yura on 03.12.15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Enumeration of available values in JSON response of gropus request
enum GroupResponseLabel: String {
    case Label = "label"
    case Value = "value"
}

// MARK: - Group struct (single record about group)

struct Group {
    
    /// Name of group
    var name: String
    
    /// Id of group
    var id: Int
    
    /**
     Initializer for group struct
     
     - parameter groupJSON:  JSON type parameter with single group record
     */
    init?(groupJSON: JSON) {
        
        if let name = groupJSON[GroupResponseLabel.Label.rawValue].string {
            self.name = name
        } else {
            return nil
        }
        
        if let id = groupJSON[GroupResponseLabel.Value.rawValue].int {
            self.id = id
        } else {
            return nil
        }
    }
}
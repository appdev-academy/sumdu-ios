//
//  Group.swift
//  SumDU
//
//  Created by Yura on 03.12.15.
//  Copyright © 2015 iOSonRails. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Enumeration of available values in JSON response of gropus request
enum GropResponseLables: String {
    case Label = "label"
    case Value = "value"
}

// MARK: - GroupDelegate protocol
protocol GroupDelegate {
    
/// Returns object of group model
    func getGroup(groupAsJson: JSON)
}

// MARK: - Group class
class Group {
    
/// Name of group
    var label: String?
    
/// Id of group
    var value: Int?
    
/// Get Group object from JSON data    
    func getGroup(groupAsJson: JSON) {
        label = groupAsJson[GropResponseLables.Label.rawValue].stringValue
        value = groupAsJson[GropResponseLables.Value.rawValue].intValue
    }
}
//
//  ScheduleCoder.swift
//  SumDU
//
//  Created by Юра on 30.01.16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Class for coding and decoding Schedule records
class ScheduleCoder: NSObject, NSCoding {
    
    // MARK: - Variables
    
    /// Schedule instance
    var schedule: Schedule?
    
    /// Initializer for ScheduleCoder class
    init(schedule: Schedule) {
        self.schedule = schedule
    }
    
    // TODO: - complete this class
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
    }
}



//
//  SectionCoder.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 2/8/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation

class SectionCoder: NSObject, NSCoding {
    
    // MARK: - Variables
    
    /// Section instance
    var section: Section?
    
    // MARK: - Initialization
    
    init(section: Section) {
        super.init()
        self.section = section
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let date = aDecoder.decodeObjectForKey("title") as? NSDate, scheduleCoders = aDecoder.decodeObjectForKey("records") as? [ScheduleCoder] {
            var scheduleArray: [Schedule] = []
            for scheduleCoder in scheduleCoders {
                if let currentSchedule = scheduleCoder.schedule {
                    scheduleArray.append(currentSchedule)
                }
            }
            section = Section(date: date, records: scheduleArray)
        }
    }
    
    // MARK: - Interface
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.section?.date, forKey: "title")
        
        var scheduleCoders: [ScheduleCoder] = []
        if let scheduleArray = self.section?.records {
            for schedule in scheduleArray {
                let currentScheduleCoder = ScheduleCoder(schedule: schedule)
                scheduleCoders.append(currentScheduleCoder)
            }
        }
        aCoder.encodeObject(scheduleCoders, forKey: "records")
    }
}
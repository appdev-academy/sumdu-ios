//
//  SectionCoder.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 2/8/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation

class SectionCoder: NSObject, NSCoding {
    
    // MARK: - Variables
    
    /// Section instance
    var section: Section?
    
    init(section: Section) {
        super.init()
        self.section = section
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let date = aDecoder.decodeObjectForKey("title") as? NSDate,
            let scheduleCoders = aDecoder.decodeObjectForKey("records") as? [ScheduleCoder] {
                var scheduleArray: [Schedule] = []
                for scheduleCoder in scheduleCoders {
                    if let currentSchedule = scheduleCoder.schedule {
                        scheduleArray.append(currentSchedule)
                    }
                }
                section = Section(date: date, records: scheduleArray)
        }
    }
    
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
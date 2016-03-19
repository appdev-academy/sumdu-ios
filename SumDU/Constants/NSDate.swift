//
//  NSDate.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 1/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation

extension NSDate {
    
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:date)
    }
    
    func dateByAddingDays(days: Int) -> NSDate {
        let timeInterval = NSTimeInterval(days*24*60*60)
        let newDate = self.dateByAddingTimeInterval(timeInterval)
        return newDate
    }
    
    func dateBySubtractingDays(days: Int) -> NSDate {
        let timeInterval = NSTimeInterval(-days*24*60*60)
        let newDate = self.dateByAddingTimeInterval(timeInterval)
        return newDate
    }
}
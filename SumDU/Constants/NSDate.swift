//
//  NSDate.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 1/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation

extension NSDate {
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
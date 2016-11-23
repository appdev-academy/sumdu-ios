//
//  NSDate.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 1/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation

extension Date {
  
  func dateByAddingDays(_ days: Int) -> Date {
    let timeInterval = TimeInterval(days*24*60*60)
    let newDate = self.addingTimeInterval(timeInterval)
    return newDate
  }
  
  func dateBySubtractingDays(_ days: Int) -> Date {
    let timeInterval = TimeInterval(-days*24*60*60)
    let newDate = self.addingTimeInterval(timeInterval)
    return newDate
  }
}

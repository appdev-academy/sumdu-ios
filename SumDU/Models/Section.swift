//
//  Section.swift
//  SumDU
//
//  Created by Yura on 07.01.16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation

class Section {
    
    /// title of section
    var date: NSDate
    
    /// array of section records
    var records: [Schedule]
    
    init(title: NSDate, records: [Schedule]) {
        self.date = title
        self.records = records
    }
}
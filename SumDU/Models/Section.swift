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
    
    var sectionCoder: SectionCoder {
        get {
            return SectionCoder(section: self)
        }
    }

    init(date: NSDate, records: [Schedule]) {
        self.date = date
        self.records = records
    }
}
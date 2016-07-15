//
//  Section.swift
//  SumDU
//
//  Created by Yura Voevodin on 07.01.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation

class Section {
    
    // MARK: - Variables
    
    /// title of section
    var date: NSDate
    
    /// array of section records
    var records: [Schedule]
    
    var sectionCoder: SectionCoder {
        get {
            return SectionCoder(section: self)
        }
    }
    
    // MARK: - Initialization
    
    init(date: NSDate, records: [Schedule]) {
        self.date = date
        self.records = records
    }
    
    // MARK: - Interface
    
    /// Save schedule information to userDefaults
    static func saveData(listDataCoder: [Section], forKey: String) {
        var sectionCoder: [SectionCoder] = []
        for sectionCoderRecord in listDataCoder {
            sectionCoder.append(sectionCoderRecord.sectionCoder)
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(sectionCoder)
        userDefaults.setObject(data, forKey: forKey)
        userDefaults.synchronize()
    }
    
    /// Load schedule information from userDefaults
    static func loadData(forKey: String) -> [Section] {
        var section: [Section] = []
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let listScheduleCoder = userDefaults.dataForKey(forKey), listScheduleDataArray = NSKeyedUnarchiver.unarchiveObjectWithData(listScheduleCoder) as? [SectionCoder] {
            
            for scheduleDataStruct in listScheduleDataArray {
                if let sectionData = scheduleDataStruct.section {
                    section.append(sectionData)
                }
            }
        }
        return section
    }
}
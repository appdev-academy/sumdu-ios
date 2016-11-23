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
  var date: Date
  
  /// array of section records
  var records: [Schedule]
  
  var sectionCoder: SectionCoder {
    get {
      return SectionCoder(section: self)
    }
  }
  
  // MARK: - Lifecycle
  
  init(date: Date, records: [Schedule]) {
    self.date = date
    self.records = records
  }
  
  // MARK: - Interface
  
  /// Save schedule information to userDefaults
  class func saveData(_ listDataCoder: [Section], forKey: String) {
    var sectionCoder: [SectionCoder] = []
    for sectionCoderRecord in listDataCoder {
      sectionCoder.append(sectionCoderRecord.sectionCoder)
    }
    let userDefaults = UserDefaults.standard
    let data = NSKeyedArchiver.archivedData(withRootObject: sectionCoder)
    userDefaults.set(data, forKey: forKey)
  }
  
  /// Load schedule information from userDefaults
  class func loadData(_ forKey: String) -> [Section] {
    var section: [Section] = []
    
    let userDefaults = UserDefaults.standard
    if let listScheduleCoder = userDefaults.data(forKey: forKey), let listScheduleDataArray = NSKeyedUnarchiver.unarchiveObject(with: listScheduleCoder) as? [SectionCoder] {
      
      for scheduleDataStruct in listScheduleDataArray {
        if let sectionData = scheduleDataStruct.section {
          section.append(sectionData)
        }
      }
    }
    return section
  }
}

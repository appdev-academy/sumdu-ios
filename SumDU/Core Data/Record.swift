//
//  Record.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation
import CoreData

@objc(Record)
public class Record: NSManagedObject {
  
  // MARK: Properties
  
  @NSManaged public var name: String
  @NSManaged public var time: String
  @NSManaged public var type: String
  @NSManaged public var auditorium: String
  @NSManaged public var teacher: String
  @NSManaged public var group: String
  @NSManaged public var date: Date
  @NSManaged public var order: String
  @NSManaged public var dayOfWeek: String
  
  // MARK: - Helpers
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
    return NSFetchRequest<Record>(entityName: "Record");
  }
  
}

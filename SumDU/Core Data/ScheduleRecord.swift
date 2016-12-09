//
//  ScheduleRecord.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/8/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation
import CoreData

@objc(ScheduleRecord)
public class ScheduleRecord: NSManagedObject {

  // MARK: Properties
  
  @NSManaged public var auditorium: String
  @NSManaged public var date: Date
  @NSManaged public var dateString: String
  @NSManaged public var dayOfWeek: String
  @NSManaged public var dayString: String
  @NSManaged public var group: String
  @NSManaged public var name: String
  @NSManaged public var order: String
  @NSManaged public var teacher: String
  @NSManaged public var time: String
  @NSManaged public var type: String
  
  // MARK: Relationships
  
  @NSManaged public var listObject: ListObject?
  
  // MARK: Overrides
  
  public override func didChangeValue(forKey key: String) {
    super.didChangeValue(forKey: key)
    
    // Set section name
    if key == "date" {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd MMMM"
      dateString = dateFormatter.string(from: date)
      dateFormatter.dateFormat = "EEEE"
      dayString = dateFormatter.string(from: date)
    }
  }
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleRecord> {
    return NSFetchRequest<ScheduleRecord>(entityName: "ScheduleRecord");
  }
  
  /// Array of mapped attributes between NSManagedObject and JSON
  static let mappedAttributes: [AttributeMapper] = [
    AttributeMapper(name: "auditorium", jsonName: "id", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "date", jsonName: "name", isOptional: false, dataType: DataType.date(format: "dd.MM.yyyy")),
    AttributeMapper(name: "dayOfWeek", jsonName: "type", isOptional: false, dataType: DataType.integer64)
  ]
  
}

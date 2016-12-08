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
  
  @NSManaged public var auditorium: String?
  @NSManaged public var date: NSDate?
  @NSManaged public var dayOfWeek: String?
  @NSManaged public var group: String?
  @NSManaged public var name: String?
  @NSManaged public var order: String?
  @NSManaged public var teacher: String?
  @NSManaged public var time: String?
  @NSManaged public var type: String?
  @NSManaged public var listObject: ListObject?
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleRecord> {
    return NSFetchRequest<ScheduleRecord>(entityName: "ScheduleRecord");
  }
  
}

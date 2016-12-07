//
//  Teacher.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation
import CoreData

@objc(Teacher)
public class Teacher: NSManagedObject {
  
  // MARK: Properties
  
  @NSManaged public var id: Int64
  @NSManaged public var name: String
  
  // MARK: - Helpers
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Teacher> {
    return NSFetchRequest<Teacher>(entityName: "Teacher");
  }
  
}

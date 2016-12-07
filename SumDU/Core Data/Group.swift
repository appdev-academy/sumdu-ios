//
//  Group.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation
import CoreData

@objc(Group)
public class Group: NSManagedObject {
  
  // MARK: Properties
  
  @NSManaged public var id: Int64
  @NSManaged public var name: String
  
  // MARK: - Constants
  
  /// Array of mapped attributes between NSManagedObject and JSON
  static let mappedAttributes: [AttributeMapper] = [
    AttributeMapper(name: "id", jsonName: "id", isOptional: false, dataType: DataType.integer64),
    AttributeMapper(name: "name", jsonName: "name", isOptional: false, dataType: DataType.string)
  ]
  
  // MARK: - Helpers
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
    return NSFetchRequest<Group>(entityName: "Group");
  }
  
}

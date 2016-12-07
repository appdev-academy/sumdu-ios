//
//  Auditorium.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation
import CoreData

@objc(Auditorium)
public class Auditorium: NSManagedObject {
  
  // MARK: Properties
  
  @NSManaged public var id: Int64
  @NSManaged public var name: String
  
  // MARK: - Helpers
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Auditorium> {
    return NSFetchRequest<Auditorium>(entityName: "Auditorium");
  }
  
}

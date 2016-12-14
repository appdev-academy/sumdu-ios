//
//  ScheduleImportManager.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/9/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import CoreDuck

/// For import schedule records form JSON
class ScheduleImportManager {
  
  /// Import records from JSON to CoreData
  ///
  /// - Parameters:
  ///   - data: array of JSON records
  ///   - listObject: object for which to store records
  ///   - attributes: Array of AttributeMapper
  func fromJSON(_ data: [Any], for listObject: ListObject) {
    NSManagedObjectContext.saveWithBlock({
      localContext in
      
      // Delete previous records
      let predicate = NSPredicate(format: "listObject = %@", listObject)
      let records = ScheduleRecord.findAll(withPredicate: predicate, inContext: localContext)
      records.forEach { record in
        localContext.delete(record)
      }
      
      // Save new persisted records
      for object in data {
        if let json = object as? [String: Any] {
          ScheduleRecord.create(from: json, with: listObject, in: localContext)
        }
      }
      
    }, completion: {
      success in
      
    })
  }
  
}

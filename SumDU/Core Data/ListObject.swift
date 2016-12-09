//
//  ListObject.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/8/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation
import CoreDuck

@objc(ListObject)
public class ListObject: NSManagedObject {
  
  // MARK: Properties
  
  @NSManaged public var firstSymbol: String
  @NSManaged public var id: Int64
  @NSManaged public var name: String
  @NSManaged public var type: Int64
  
  // MARK: Relationships
  
  @NSManaged public var scheduleRecords: NSSet
  
  // MARK: Overrides
  
  public override func didChangeValue(forKey key: String) {
    super.didChangeValue(forKey: key)
    
    if key == "name" {
      if let firstSymbol = self.name.characters.first {
        self.firstSymbol = String(firstSymbol).uppercased()
      } else {
        self.firstSymbol = ""
      }
    }
  }
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ListObject> {
    return NSFetchRequest<ListObject>(entityName: "ListObject");
  }
  
  /// Array of mapped attributes between NSManagedObject and JSON
  static let mappedAttributes: [AttributeMapper] = [
    AttributeMapper(name: "id", jsonName: "id", isOptional: false, dataType: DataType.integer64),
    AttributeMapper(name: "name", jsonName: "name", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "type", jsonName: "type", isOptional: false, dataType: DataType.integer64)
  ]
  
  // MARK: Generated accessors for scheduleRecords
  
  @objc(addScheduleRecordsObject:)
  @NSManaged public func addToScheduleRecords(_ value: ScheduleRecord)
  
  @objc(removeScheduleRecordsObject:)
  @NSManaged public func removeFromScheduleRecords(_ value: ScheduleRecord)
  
  @objc(addScheduleRecords:)
  @NSManaged public func addToScheduleRecords(_ values: NSSet)
  
  @objc(removeScheduleRecords:)
  @NSManaged public func removeFromScheduleRecords(_ values: NSSet)
  
  // MARK: - Helpers
  
  /// Create NSFetchedResultsController with search and sections
  ///
  /// - Parameters:
  ///   - text: search text
  ///   - delegate: entity that will be delegate
  /// - Returns: NSFetchedResultsController<ListObject>
  static func fetch(search text: String?, type: ContentType, delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<ListObject> {
    var predicates: [NSPredicate] = []
    
    // Search
    let searchText = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    if let text = searchText, text.characters.count > 0 {
      predicates.append(NSPredicate(format: "name contains[cd] %@", text))
    }
    
    // Type
    predicates.append(NSPredicate(format: "type = \(type.rawValue)"))
    
    // Initialize Fetch Request
    let request: NSFetchRequest<ListObject> = fetchRequest()
    request.fetchBatchSize = 20
    
    // Sort
    let letterDescriptor = NSSortDescriptor(key: "firstSymbol", ascending: true)
    let nameDescriptor = NSSortDescriptor(key: "name", ascending: true)
    request.sortDescriptors = [letterDescriptor, nameDescriptor]
    
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    request.predicate = compoundPredicate
    
    // Initialize Fetched Results Controller
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDuck.quack.mainContext, sectionNameKeyPath: "firstSymbol", cacheName: nil)
    
    // Set delegate
    fetchedResultsController.delegate = delegate
    
    // Try to perform fetch request
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Failed to initialize FetchedResultsController: \(error)")
    }
    
    return fetchedResultsController
  }
  
}

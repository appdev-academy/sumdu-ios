//
//  ScheduleRecord.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/8/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import CoreDuck

@objc(ScheduleRecord)
public class ScheduleRecord: NSManagedObject {
  
  // MARK: Properties
  
  @NSManaged public var auditorium: String
  @NSManaged public var date: Date
  @NSManaged public var dayOfWeek: String
  @NSManaged public var group: String
  @NSManaged public var name: String
  @NSManaged public var order: String
  @NSManaged public var teacher: String
  @NSManaged public var time: String
  @NSManaged public var type: String
  
  // MARK: Sections
  
  @NSManaged public var dateString: String
  @NSManaged public var dayString: String
  
  // MARK: Relationships
  
  @NSManaged public var listObject: ListObject
  
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
    AttributeMapper(name: "auditorium", jsonName: "NAME_AUD", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "date", jsonName: "DATE_REG", isOptional: false, dataType: DataType.date(format: "dd.MM.yyyy")),
    AttributeMapper(name: "dayOfWeek", jsonName: "NAME_WDAY", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "group", jsonName: "NAME_GROUP", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "name", jsonName: "ABBR_DISC", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "order", jsonName: "NAME_PAIR", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "teacher", jsonName: "NAME_FIO", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "time", jsonName: "TIME_PAIR", isOptional: false, dataType: DataType.string),
    AttributeMapper(name: "type", jsonName: "NAME_STUD", isOptional: false, dataType: DataType.string),
    ]
  
  // MARK: - Helpers
  
  /// Find existing in CoreData or create new one
  ///
  /// - Parameters:
  ///   - json: Array with JSON data
  ///   - mappedAttributes: Array of AttributeMapper
  ///   - context: to work with object
  static func create(from json: [String: Any], with listObject: ListObject, in context: NSManagedObjectContext) {
    // Create a new one
    guard let newObject = ScheduleRecord.new(inContext: context) as? ScheduleRecord else { return }
    guard let listObject = listObject.inContext(context) as? ListObject else { return }
      newObject.update(with: json, mappedAttributes: ScheduleRecord.mappedAttributes)
      newObject.listObject = listObject
  }
  
  /// Create NSFetchedResultsController with sections
  ///
  /// - Parameter listObject: object for which fetch records
  /// - Returns: NSFetchedResultsController<ScheduleRecord>
  static func fetch(for listObject: ListObject, delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<ScheduleRecord> {
    var predicates: [NSPredicate] = []
    
    // Owner
    predicates.append(NSPredicate(format: "listObject = %@", listObject))
   
    // Initialize Fetch Request
    let request: NSFetchRequest<ScheduleRecord> = fetchRequest()
    request.fetchBatchSize = 20
    
    // Sort
    let dateStringDescriptor = NSSortDescriptor(key: "date", ascending: true)
    let dateDescriptor = NSSortDescriptor(key: "time", ascending: true)
    request.sortDescriptors = [dateStringDescriptor, dateDescriptor]
    
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    request.predicate = compoundPredicate
    
    // Initialize Fetched Results Controller
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDuck.quack.mainContext, sectionNameKeyPath: "dateString", cacheName: nil)
    
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

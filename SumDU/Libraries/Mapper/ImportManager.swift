//
//  ImportManager.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import CoreDuck

/// Notify delegate about result of import
protocol ImportManagerDelegate {
  
  func didFinishImport()
  
  func didFailImport()
}

/// For import NSManagedObjects from JSON
class ImportManager<Type: NSManagedObject> {
		
  var delegate: ImportManagerDelegate?
  
  // TODO: Move attributes: [AttributeMapper] to protocol
  
  func fromJSON(_ data: [Any], mappedAttributes attributes: [AttributeMapper]) {
    NSManagedObjectContext.saveWithBlock({
      localContext in
      
      // Save all IDs
      var objectsIDs: [NSManagedObjectID] = []
      
      // Save new and update persisted records
      for object in data {
        if let json = object as? [String: Any] {
          if let savedObject = Type.createOrUpdate(json, mappedAttributes: attributes, context: localContext) {
            objectsIDs.append(savedObject.objectID)
          }
        }
      }
      
      // TODO: Check logic of deletion objects
      
      // Loop through all records in context and remove the ones without match of entityID in array of entity IDs from JSON
      let persistedObjects = Type.findAll(inContext: localContext)
      for persistedObject in persistedObjects {
        if !objectsIDs.contains(persistedObject.objectID) {
          localContext.delete(persistedObject)
        }
      }
      
    }, completion: {
      success in
      
      if success {
        self.delegate?.didFinishImport()
      } else {
        self.delegate?.didFailImport()
      }
    })
  }
  
}

// MARK: - NSManagedObject

extension NSManagedObject {
  
  /// Find existing in CoreData or create new one
  ///
  /// - Parameters:
  ///   - json: Array with JSON data
  ///   - mappedAttributes: Array of AttributeMapper
  ///   - context: to work with object
  static func createOrUpdate(_ json: [String: Any], mappedAttributes: [AttributeMapper], context: NSManagedObjectContext) -> NSManagedObject? {
    let idMappedAttribute = mappedAttributes[0]
    
    // Getting id
    guard let id = json[idMappedAttribute.jsonName] else { return nil }
    guard let objectID = Converter.convertToInt64(id, attribute: idMappedAttribute) else { return nil }
    
    // TODO: Print errors
    
    // Find existing
    if let persistedObject = self.findFirst(byAttribute: idMappedAttribute.name, withInt64Value: objectID, inContext: context) {
      persistedObject.update(with: json, mappedAttributes: mappedAttributes)
      
      return persistedObject
      
    } else {
      // Or create a new one
      let newObject = self.new(inContext: context)
      newObject.update(with: json, mappedAttributes: mappedAttributes)
      
      return newObject
    }
  }
  
}

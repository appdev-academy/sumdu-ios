//
//  NSManagedObject.swift
//  Mapper
//
//  Created by Yura Voevodin on 10/28/16.
//  Copyright © 2016 Yura Voevodin. All rights reserved.
//

import CoreData

extension NSManagedObject {
  
  // MARK: - Properties
  
  /// Entity name of NSManagedObject for debug
  fileprivate var debugEntityName: String {
    var entityName = "NSManagedObject"
    if let name = self.entity.name {
      entityName = name + " (NSManagedObject subclass)"
    }
    return entityName
  }
  
  // MARK: - Update from JSON
  
  /// Update NSManagedObject with data from JSON
  ///
  /// - Parameters:
  ///   - json: Array with JSON data
  ///   - mappedAttributes: Array of AttributeMapper
  func update(with json: [String: Any], mappedAttributes: [AttributeMapper]) {
    
    // Attributes from NSManagedObject
    let entityAttributes = entity.attributesByName
    
    // Loop through mapped attributes
    for mappedAttribute in mappedAttributes {
      
      // Check if NSManagedObject has key from mapped attributes
      guard let entityAttribute = checkAttribute(in: entityAttributes, with: mappedAttribute) else {
        return
      }
      
      // Check isOptional
      guard checkIfOptionalCorrect(for: entityAttribute, and: mappedAttribute) else {
        return
      }
      
      // Check type of data
      compareDataType(of: entityAttribute, and: mappedAttribute)
      
      // Get JSON value from array
      guard let jsonValue = json[mappedAttribute.jsonName] else {
        continue
      }
      
      let attributeName = mappedAttribute.name
      
      /// Set value for attribute by key
      ///
      /// - Parameter value: Any? value for update
      func updateAttributeWithValue(value: Any?) {
        willChangeValue(forKey: attributeName)
        setValue(value, forKey: attributeName)
        didChangeValue(forKey: attributeName)
      }
      
      // Check attribute type and set value
      switch mappedAttribute.dataType {
      case .boolean:
        if let booleanValue = Converter.convertToBoolean(jsonValue, attribute: mappedAttribute) {
          updateAttributeWithValue(value: booleanValue)
        } else if mappedAttribute.isOptional {
          updateAttributeWithValue(value: false)
        }
        
      case .date(let format):
        if let dateValue = Converter.convertToDate(jsonValue, format: format, attribute: mappedAttribute) {
          updateAttributeWithValue(value: dateValue)
        } else if mappedAttribute.isOptional {
          updateAttributeWithValue(value: nil)
        }
        
      case .double:
        if let doubleValue = Converter.convertToDouble(jsonValue, attribute: mappedAttribute) {
          updateAttributeWithValue(value: doubleValue)
        } else if mappedAttribute.isOptional {
          updateAttributeWithValue(value: 0)
        }
        
      case .float:
        if let floatValue = Converter.convertToFloat(jsonValue, attribute: mappedAttribute) {
          updateAttributeWithValue(value: floatValue)
        } else if mappedAttribute.isOptional {
          updateAttributeWithValue(value: 0)
        }
        
      case .integer16:
        if let int16Value = Converter.convertToInt16(jsonValue, attribute: mappedAttribute) {
          updateAttributeWithValue(value: int16Value)
        } else if mappedAttribute.isOptional {
          updateAttributeWithValue(value: 0)
        }
        
      case .integer32:
        if let int32Value = Converter.convertToInt32(jsonValue, attribute: mappedAttribute) {
          updateAttributeWithValue(value: int32Value)
        } else if mappedAttribute.isOptional {
          updateAttributeWithValue(value: 0)
        }
        
      case .integer64:
        if let int64Value = Converter.convertToInt64(jsonValue, attribute: mappedAttribute) {
          updateAttributeWithValue(value: int64Value)
        } else if mappedAttribute.isOptional {
          updateAttributeWithValue(value: 0)
        }
        
      case .string:
        if let stringValue = Converter.convertToString(jsonValue, attribute: mappedAttribute) {
          updateAttributeWithValue(value: stringValue)
        } else if mappedAttribute.isOptional {
          updateAttributeWithValue(value: nil)
        }
      }
    }
  }
  
  // MARK: - Convert to JSON
  
  /// Convert NSManagedObject to valid JSON object
  ///
  /// - Parameter mappedAttributes: Array of AttributeMapper
  func convertToJSON(with mappedAttributes: [AttributeMapper]) -> [String: Any] {
    var json: [String: Any] = [:]
    
    // Attributes from NSManagedObject
    let entityAttributes = entity.attributesByName
    
    // Loop through mapped attributes
    for mappedAttribute in mappedAttributes {
      
      // Check if NSManagedObject has key from mapped attributes
      guard let entityAttribute = checkAttribute(in: entityAttributes, with: mappedAttribute) else {
        return [:]
      }
      
      // Check isOptional
      guard checkIfOptionalCorrect(for: entityAttribute, and: mappedAttribute) else {
        return [:]
      }
      
      // Check type of data
      compareDataType(of: entityAttribute, and: mappedAttribute)
      
      let attributeName = mappedAttribute.name
      
      var jsonValue: Any?
      
      // Check attribute type and set value
      switch mappedAttribute.dataType {
        
      case .boolean(let style):
        guard let booleanStyle = style else {
          print("⚠️ Provide style of Bool value for `\(attributeName)` for convert to JSON")
          return [:]
        }
        var valueToConvert = false
        if let booleanValue = value(forKey: attributeName) as? Bool {
          valueToConvert = booleanValue
        }
        jsonValue = Converter.booleanToJson(valueToConvert, style: booleanStyle)
        
      case .date(let format):
        if let dateString = Converter.dateToString(value(forKey: attributeName) as? Date, format: format) {
          jsonValue = dateString
        }
        
      case .double:
        if let doubleValue = value(forKey: attributeName) as? Double {
          jsonValue = doubleValue
        } else {
          jsonValue = Double(0)
        }
        
      case .float:
        if let floatValue = value(forKey: attributeName) as? Float {
          jsonValue = floatValue
        } else {
          jsonValue = Float(0)
        }
        
      case .integer16:
        if let int16Value = value(forKey: attributeName) as? Int16 {
          jsonValue = int16Value
        } else {
          jsonValue = Int16(0)
        }
        
      case .integer32:
        if let int32Value = value(forKey: attributeName) as? Int32 {
          jsonValue = int32Value
        } else {
          jsonValue = Int32(0)
        }
        
      case .integer64:
        if let int64Value = value(forKey: attributeName) as? Int64 {
          jsonValue = int64Value
        } else {
          jsonValue = Int64(0)
        }
        
      case .string:
        if let stringValue = value(forKey: attributeName) as? String {
          jsonValue = stringValue
        }
      }
      
      if let value = jsonValue {
        json[mappedAttribute.jsonName] = value
      }
    }
    
    return json
  }
  
  // MARK: - Helpers
  
  /// Check if NSAttributeDescription of NSManagedObject has equal type of data with AttributeMapper
  ///
  /// - Parameters:
  ///   - entityAttribute: NSAttributeDescription
  ///   - mappedAttribute: AttributeMapper
  fileprivate func compareDataType(of entityAttribute: NSAttributeDescription, and mappedAttribute: AttributeMapper) {
    
    switch entityAttribute.attributeType {
    case .integer16AttributeType:
      guard mappedAttribute.dataType == .integer16 else {
        printWrongAttributeType(mappedAttribute, entityAttribute)
        return
      }
    case .integer32AttributeType:
      guard mappedAttribute.dataType == .integer32 else {
        printWrongAttributeType(mappedAttribute, entityAttribute)
        return
      }
    case .integer64AttributeType:
      guard mappedAttribute.dataType == .integer64 else {
        printWrongAttributeType(mappedAttribute, entityAttribute)
        return
      }
    case .doubleAttributeType:
      guard mappedAttribute.dataType == .double else {
        printWrongAttributeType(mappedAttribute, entityAttribute)
        return
      }
    case .floatAttributeType:
      guard mappedAttribute.dataType == .float else {
        printWrongAttributeType(mappedAttribute, entityAttribute)
        return
      }
    case .stringAttributeType:
      guard mappedAttribute.dataType == .string else {
        printWrongAttributeType(mappedAttribute, entityAttribute)
        return
      }
    case .booleanAttributeType:
      guard mappedAttribute.dataType == .boolean(style: Converter.BooleanStyle.number) else {
        printWrongAttributeType(mappedAttribute, entityAttribute)
        return
      }
    case .dateAttributeType:
      guard mappedAttribute.dataType == DataType.date(format: "") else {
        printWrongAttributeType(mappedAttribute, entityAttribute)
        return
      }
    default:
      printWrongAttributeType(mappedAttribute, entityAttribute)
    }
  }
  
  /// Print warning to console about wrong type in AttributeMapper
  ///
  /// - Parameters:
  ///   - mappedAttribute: AttributeMapper value
  ///   - attributeDescription: NSAttributeDescription
  fileprivate func printWrongAttributeType(_ mappedAttribute: AttributeMapper, _ attributeDescription: NSAttributeDescription) {
    print("⚠️ \(self.debugEntityName) attribute: `\(attributeDescription.name)` type not equals to `\(mappedAttribute.name)` type in AttributeMapper")
  }
  
  /// Check if NSManagedObject has key from mapped attributes
  ///
  /// - Parameters:
  ///   - entityAttributes: Array of attributes for NSManagedObject
  ///   - mappedAttribute: Array of AttributeMapper
  /// - Returns: NSAttributeDescription
  fileprivate func checkAttribute(in entityAttributes: [String : NSAttributeDescription], with mappedAttribute: AttributeMapper) -> NSAttributeDescription? {
    
    // Check if NSManagedObject has key from mapped attributes
    let entityAttribute = entityAttributes.first(where: { key, value -> Bool in
      return mappedAttribute.name == key
    })
    
    if let attribute = entityAttribute {
      return attribute.value
    } else {
      print("⚠️ \(debugEntityName) do not have attribute '\(mappedAttribute.name)'")
      return nil
    }
  }
  
  /// Check isOptional
  ///
  /// - Parameters:
  ///   - entityAttribute: NSAttributeDescription for entity
  ///   - mappedAttribute: AttributeMapper value
  /// - Returns: Bool
  fileprivate func checkIfOptionalCorrect(for entityAttribute: NSAttributeDescription, and mappedAttribute: AttributeMapper) -> Bool {
    if entityAttribute.isOptional == mappedAttribute.isOptional {
      return true
    } else {
      print("⚠️ \(debugEntityName) attribute: `\(entityAttribute.name).isOptional = \(entityAttribute.isOptional)` not equals to `\(mappedAttribute.name)` `isOptional = \(mappedAttribute.isOptional)` in AttributeMapper")
      return false
    }
  }
  
}

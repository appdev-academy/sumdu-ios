//
//  Converter.swift
//  Mapper
//
//  Created by Yura Voevodin on 11/2/16.
//  Copyright © 2016 Yura Voevodin. All rights reserved.
//

import Foundation


/// Structure for convert data from JSON object to standard type
struct Converter {
  
  /// Style of boolean value in JSON
  ///
  /// - number: 0 or 1 as NSNumber
  /// - numberString: "0" or "1" as String
  /// - string: "true" or "false" as String
  enum BooleanStyle {
    case number
    case numberString
    case string
  }
  
  // MARK: - From JSON
  
  /// Convert value from JSON array to Int16
  ///
  /// - Parameters:
  ///   - jsonObject: Value from JSON to convert
  ///   - attribute: AttributeMapper
  /// - Returns: Int16 value or nil
  static func convertToInt16(_ jsonObject: Any, attribute: AttributeMapper) -> Int16? {
    guard let number = jsonObject as? NSNumber else {
      print("⚠️ Can't convert \(attribute.jsonName) to Int16")
      return nil
    }
    return number.int16Value
  }
  
  /// Convert value from JSON array to Int32
  ///
  /// - Parameters:
  ///   - jsonObject: Value from JSON to convert
  ///   - attribute: AttributeMapper
  /// - Returns: Int32 value or nil
  static func convertToInt32(_ jsonObject: Any, attribute: AttributeMapper) -> Int32? {
    guard let number = jsonObject as? NSNumber else {
      print("⚠️ Can't convert \(attribute.jsonName) to Int32")
      return nil
    }
    return number.int32Value
  }
  
  /// Convert value from JSON array to Int64
  ///
  /// - Parameters:
  ///   - jsonObject: Value from JSON to convert
  ///   - attribute: AttributeMapper
  /// - Returns: Int64 value or nil
  static func convertToInt64(_ jsonObject: Any, attribute: AttributeMapper) -> Int64? {
    guard let number = jsonObject as? NSNumber else {
      print("⚠️ Can't convert \(attribute.jsonName) to Int64")
      return nil
    }
    return number.int64Value
  }
  
  /// Convert value from JSON array to Date
  ///
  /// - Parameters:
  ///   - jsonObject: Value from JSON to convert
  ///   - format: String with Date format
  ///   - attribute: AttributeMapper
  /// - Returns: Date value or nil
  static func convertToDate(_ jsonObject: Any, format: String, attribute: AttributeMapper) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    
    if let dateString = jsonObject as? String, let dateValue = formatter.date(from: dateString) {
      return dateValue
    }
    print("⚠️ Can't convert \(attribute.jsonName) to Date")
    return nil
  }
  
  /// Convert value from JSON array to String
  ///
  /// - Parameters:
  ///   - jsonObject: Value from JSON to convert
  ///   - attribute: AttributeMapper
  /// - Returns: String value or nil
  static func convertToString(_ jsonObject: Any, attribute: AttributeMapper) -> String? {
    guard let stringValue = jsonObject as? String else {
      print("⚠️ Can't convert \(attribute.jsonName) to String")
      return nil
    }
    return stringValue
  }
  
  /// Convert value from JSON array to Bool
  ///
  /// - Parameters:
  ///   - jsonObject: Value from JSON to convert
  ///   - attribute: AttributeMapper
  /// - Returns: Bool value or nil
  static func convertToBoolean(_ jsonObject: Any, attribute: AttributeMapper) -> Bool? {
    // NSNumber
    if let booleanValue = jsonObject as? NSNumber {
      return booleanValue.boolValue
    }
    // String
    if let booleanValue = jsonObject as? String {
      // "true" and "false"
      // "1" and "0"
      if booleanValue == "true" {
        return true
      } else if booleanValue == "false" {
        return false
      } else if booleanValue == "1" {
        return true
      } else if booleanValue == "0" {
        return false
      }
    }
    print("⚠️ Can't convert \(attribute.jsonName) to Bool")
    return nil
  }
  
  /// Convert value from JSON array to Double
  ///
  /// - Parameters:
  ///   - jsonObject: Value from JSON to convert
  ///   - attribute: AttributeMapper
  /// - Returns: Double value or nil
  static func convertToDouble(_ jsonObject: Any, attribute: AttributeMapper) -> Double? {
    guard let doubleValue = jsonObject as? Double else {
      print("⚠️ Can't convert \(attribute.jsonName) to Double")
      return nil
    }
    return doubleValue
  }
  
  /// Convert value from JSON array to Float
  ///
  /// - Parameters:
  ///   - jsonObject: Value from JSON to convert
  ///   - attribute: AttributeMapper
  /// - Returns: Float value or nil
  static func convertToFloat(_ jsonObject: Any, attribute: AttributeMapper) -> Float? {
    guard let floatValue = jsonObject as? Float else {
      print("⚠️ Can't convert \(attribute.jsonName) to Float")
      return nil
    }
    return floatValue
  }
  
  // MARK: - To JSON
  
  /// Convert boolean value to JSON
  ///
  /// - Parameters:
  ///   - booleanValue: Bool
  ///   - style: style of the `booleanValue` BooleanStyle
  /// - Returns: Any
  static func booleanToJson(_ booleanValue: Bool, style: BooleanStyle) -> Any {
    switch style {
    case .number:
      return NSNumber(value: booleanValue)
      
    case .numberString:
      let booleanLiteral = NSNumber(value: booleanValue)
      return "\(booleanLiteral)"
      
    case .string:
      return booleanValue ? "true" : "false"
    }
  }
  
  /// Convert Date value to String
  ///
  /// - Parameters:
  ///   - dateValue: Date?
  ///   - format: of the Date
  /// - Returns: String representation of the date or nil
  static func dateToString(_ dateValue: Date?, format: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    
    if let date = dateValue {
      return dateFormatter.string(from: date)
    }
    return nil
  }
  
}

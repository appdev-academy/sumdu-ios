//
//  AttributeMapper.swift
//  Mapper
//
//  Created by Yura Voevodin on 10/28/16.
//  Copyright © 2016 Yura Voevodin. All rights reserved.
//

import Foundation

/// Type of data for `AttributeMapper`
///
/// - Bool: Boolean with true and false values
/// - Date: Date with format
/// - Double: Double
/// - Int: Int
/// - String: String
enum DataType: Equatable {
  case integer16
  case integer32
  case integer64
  case double
  case float
  case string
  case boolean(style: Converter.BooleanStyle?)
  case date(format: String)
  
  var number: Int {
    switch self {
    case .integer16:
      return 0
    case .integer32:
      return 1
    case .integer64:
      return 2
    case .double:
      return 3
    case .float:
      return 4
    case .string:
      return 5
    case .boolean:
      return 6
    case .date:
      return 7
    }
  }
  
  public static func ==(lhs: DataType, rhs: DataType) -> Bool {
    return lhs.number == rhs.number
  }
}

/// Structure for map attribute of CoreData entity to JSON object
struct AttributeMapper {
  
  /// Name of attribute in CoreData entity
  var name: String
  
  /// Name of attribute in JSON object
  var jsonName: String
  
  /// Is this optional attribute or not
  var isOptional: Bool
  
  /// Type of data in attribute
  var dataType: DataType
}

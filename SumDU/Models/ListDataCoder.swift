//
//  ListData.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 12/11/15.
//  Copyright © 2015 App Dev Academy. All rights reserved.
//

import Foundation
import SwiftyJSON


/// Class for coding and decoding Auditorium, Group or Teacher
class ListDataCoder: NSObject, NSCoding {
  
  // MARK: - Variables
  
  /// ListData instance
  var listData: ListData?
  
  // MARK: - Lifecycle
  
  /// Initializer for LisaDataCoder class
  init(listData: ListData) {
    self.listData = listData
  }
  
  /// Decode ListData enities: Auditorium, Group or Teacher
  required init(coder aDecoder: NSCoder) {
    if let id = aDecoder.decodeObject(forKey: "id") as? Int,
      let name = aDecoder.decodeObject(forKey: "name") as? String,
      let type = aDecoder.decodeObject(forKey: "type") as? String,
      let listDataType = ListDataType(rawValue: type) {
      self.listData = ListData(id: id, name: name, type: listDataType)
    }
  }
  
  // MARK: - Public interface
  
  /// Serialize ListData enities: Auditorium, Group or Teacher
  func encode(with coder: NSCoder) {
    coder.encode(listData?.id, forKey: "id")
    coder.encode(listData?.name, forKey: "name")
    coder.encode(listData?.type.rawValue, forKey: "type")
  }
}

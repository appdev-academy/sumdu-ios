//
//  ListData.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 12/11/15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON


/// Class for coding and decoding Auditorium, Group or Teacher
class ListDataCoder: NSObject, NSCoding {
    
    // MARK: - Variables
    
    /// ListData instance
    var listData: ListData?
    
    /// Initializer for LisaDataCoder class
    init(listData: ListData) {
        self.listData = listData
    }
    
    /// Decode ListData enities: Auditorium, Group or Teacher
    required init(coder aDecoder: NSCoder) {
        if let id = aDecoder.decodeObjectForKey("id") as? Int,
            let name = aDecoder.decodeObjectForKey("name") as? String,
            let type = aDecoder.decodeObjectForKey("type") as? String,
            let listDataType = ListDataType(rawValue: type) {
                self.listData = ListData(id: id, name: name, type: listDataType)
        }
    }
    
    /// Serialize ListData enities: Auditorium, Group or Teacher
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(listData?.id, forKey: "id")
        coder.encodeObject(listData?.name, forKey: "name")
        coder.encodeObject(listData?.type.rawValue, forKey: "type")
    }
}
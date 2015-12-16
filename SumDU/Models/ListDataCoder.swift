//
//  ListData.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 12/11/15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

extension ListData {
    
    class ListDataCoder: NSObject, NSCoding {
        
        var listData: ListData?
        
        init(listData: ListData) {
            self.listData = listData
        }
        
        required init(coder aDecoder: NSCoder) {
            if let id = aDecoder.decodeObjectForKey("id") as? Int,
                let name = aDecoder.decodeObjectForKey("name") as? String,
                let type = aDecoder.decodeObjectForKey("type") as? String,
                let listDataType = ListDataType(rawValue: type) {
                    self.listData = ListData(id: id, name: name, type: listDataType)
            }
        }
        
        func encodeWithCoder(coder: NSCoder) {
            coder.encodeObject(listData?.id, forKey: "id")
            coder.encodeObject(listData?.name, forKey: "name")
            coder.encodeObject(listData?.type.rawValue, forKey: "type")
        }
    }
}
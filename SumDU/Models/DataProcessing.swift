//
//  DataProcessing.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 12/11/15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import Foundation
import SwiftyJSON

extension ListData {
    
    class DataProcessing: NSObject, NSCoding {
        
        //let id: Int
        //let name: String
        
        var boroda: ListData?
        
        override init() {
            //self.id = id
            //self.name = name
            //super.init()
        }
    
       required init(coder Decoder: NSCoder) {
            if let id = Decoder.decodeObjectForKey("id") as? Int {
                self.boroda.id = id
            }
            name = Decoder.decodeObjectForKey("name") as! String
        }
    
        func encodeWithCoder(Coder: NSCoder) {
            Coder.encodeObject(id, forKey: "id")
            Coder.encodeObject(name, forKey: "name")
        }
        
        class func path() -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
            let path = documentsPath?.stringByAppendingString("/Resources")
            return path!
        }
    }
}
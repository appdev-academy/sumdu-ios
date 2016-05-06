//
//  SearchTextField.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/4/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class SearchTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure self
        self.textAlignment = .Left
        self.textColor = colorForSelectedObjects
        self.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 245.0/255, alpha: 1.0)
        self.font = titleTextFont
        self.layer.cornerRadius = 6.0
        self.layer.zPosition = 1.0
        self.leftViewMode = .Always
        self.sizeToFit()
        
        // Configure placeholder
        self.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSForegroundColorAttributeName: defaultColorForObjects, NSFontAttributeName: titleTextFont])
        
    }
}

//
//  SearchTextField.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/4/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import UIKit

class SearchTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        textAlignment = .Left
        textColor = colorForSelectedObjects
        font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 17.0)
        layer.cornerRadius = 6.0
        layer.zPosition = 1.0
        leftViewMode = .Always
        sizeToFit()
        
        // Configure placeholder
        let attributes = [NSForegroundColorAttributeName: defaultColorForObjects, NSFontAttributeName: FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 17.0)]
        let placeholderText = NSLocalizedString("Search", comment: "")
        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
    }
}
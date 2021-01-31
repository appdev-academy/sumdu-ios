//
//  SearchTextField.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/4/16.
//  Copyright © 2016 App Dev Academy Ltd. All rights reserved.
//

import Foundation
import UIKit

class SearchTextField: UITextField {
  
  // MARK: - Initialization
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    textAlignment = .left
    textColor = Color.textBlack
    font = Font.named(.helveticaNeueMedium, size: 17.0)
    layer.cornerRadius = 6.0
    layer.zPosition = 1.0
    leftViewMode = .always
    sizeToFit()
    
    // Configure placeholder
    let attributes = [NSAttributedString.Key.foregroundColor: Color.textLight, NSAttributedString.Key.font: Font.named(.helveticaNeueMedium, size: 17.0)]
    let placeholderText = NSLocalizedString("Search", comment: "")
    attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
  }
}

//
//  UIAlertController.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/8/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import UIKit

extension UIAlertController {
  
  /// Add default ok button
  func addOkButton() {
    let buttonTitle = NSLocalizedString("OK", comment: "Alert button title")
    let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
    self.addAction(action)
  }
  
}

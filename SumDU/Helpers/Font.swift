//
//  Font.swift
//  SumDU
//
//  Created by Yura Voevodin on 13.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import UIKit

/// Enumeration of all app fonts
enum FontName: String {
  case helveticaNeueMedium    = "HelveticaNeue-Medium"
  case helveticaNeueRegular   = "HelveticaNeue-Regular"
}

/// Get all app fonts throught this struct
struct Font {
  
  /// Get UIFont with specified name and size
  ///
  /// - parameter name: FontName value
  /// - parameter size: Font size
  ///
  /// - returns: UIFont object with specified font name and size
  static func named(_ name: FontName, size: CGFloat) -> UIFont {
    guard let font = UIFont(name: name.rawValue, size: size) else {
      // Fallback to system font if not found
      return UIFont.systemFont(ofSize: size)
    }
    return font
  }
}

//
//  FontManager.swift
//  SumDU
//
//  Created by Yura Voevodin on 13.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import UIKit

/// Enumeration of all app fonts
enum FontName {
    case HelveticaNeueMedium
    case HelveticaNeueRegular
    
    var name: String {
        switch self {
        case .HelveticaNeueMedium: return "HelveticaNeue-Medium"
        case .HelveticaNeueRegular: return "HelveticaNeue-Regular"
        }
    }
}

/// Get all app fonts throught this struct
struct FontManager {
    
    /**
        Get UIFont
     
        - parameter name: FontName value
        - parameter size: size of the font
    */
    static func getFont(name font: FontName, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: font.name, size: size) else {
            // Fallback to system font if not found
            return UIFont.systemFontOfSize(size)
        }
        return font
    }
}
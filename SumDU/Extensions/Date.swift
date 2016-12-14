//
//  Date.swift
//  SumDU
//
//  Created by Yura Voevodin on 12/9/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation

extension Date {
  
  /// String representation of the date in server format
  public var serverDateFormat: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    let locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = locale
    return dateFormatter.string(from: self)
  }
  
}

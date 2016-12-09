//
//  UserDefaultsKey.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 12/19/15.
//  Copyright © 2015 App Dev Academy. All rights reserved.
//


import Foundation

private let userDefaultsPrefix: String = "academy.appdev.sumdu.user-defaults"

enum UserDefaultsKey: String {
  case LastUpdatedAtDate  = "last-updated-at-date"
  
  var key: String {
    get {
      return userDefaultsPrefix + self.rawValue
    }
  }
}

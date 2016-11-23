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
  case Auditoriums        = "auditoriums"
  case Groups             = "groups"
  case Teachers           = "teachers"
  case LastUpdatedAtDate  = "last-updated-at-date"
  case History            = "history"
  case Section            = "section"
  case ScheduleListData   = "listdata-for-schedule"
  
  var key: String {
    get {
      return userDefaultsPrefix + self.rawValue
    }
  }
  
  static func scheduleKey(_ listData: ListData) -> String {
    switch listData.type {
    case .Auditorium:
      return userDefaultsPrefix + "-auditorium-\(listData.id)"
    case .Group:
      return userDefaultsPrefix + "-group-\(listData.id)"
    case .Teacher:
      return userDefaultsPrefix + "-teacher-\(listData.id)"
    }
  }
}

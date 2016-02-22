//
//  UserDefaultsKey.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 12/19/15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//


import Foundation

let userDefaultsPrefix: String = "academy.appdev.sumdu.user-defaults"

enum UserDefaultsKey: String {
    case Auditoriums = "auditoriums"
    case Groups = "groups"
    case Teachers = "teachers"
    case LastUpdatedAtDate = "last-updated-at-date"
    case History = "history"
    case ButtonPressed = "is-refresh-button-pressed"
    case Section = "Section"
    case IsConnetionPresent = "is-connection-present"
    
    var key: String {
        get {
            switch self {
                case .Auditoriums:
                    return userDefaultsPrefix + Auditoriums.rawValue
                case .Groups:
                    return userDefaultsPrefix + Groups.rawValue
                case .Teachers:
                    return userDefaultsPrefix + Teachers.rawValue
                case .LastUpdatedAtDate:
                    return userDefaultsPrefix + LastUpdatedAtDate.rawValue
                case .History:
                    return userDefaultsPrefix + History.rawValue
                case .ButtonPressed:
                    return userDefaultsPrefix + ButtonPressed.rawValue
                case .Section:
                    return userDefaultsPrefix + Section.rawValue
                case .IsConnetionPresent:
                    return userDefaultsPrefix + IsConnetionPresent.rawValue
            }
        }
    }
    
    static func scheduleKey(listData: ListData) -> String {
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
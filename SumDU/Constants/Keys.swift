//
//  Keys.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 12/19/15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

let prefix: String = "academy.appdev.sumdu."

enum Key: String {
    case Auditoriums = "auditoriums"
    case Groups = "groups"
    case Teachers = "teachers"
    case LastUpdatedAtDate = "last-updated-at-date"
    case History = "history"
    case ButtonPressed = "is-refresh-button-pressed"
    
    static func getKey(key: Key) -> String {
        switch key {
            case .Auditoriums:
                return prefix + Auditoriums.rawValue
            case .Groups:
                return prefix + Groups.rawValue
            case .Teachers:
                return prefix + Teachers.rawValue
            case .LastUpdatedAtDate:
                return prefix + LastUpdatedAtDate.rawValue
            case .History:
                return prefix + History.rawValue
            case .ButtonPressed:
                return prefix + ButtonPressed.rawValue
        }
    }
}


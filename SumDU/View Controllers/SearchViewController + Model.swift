//
//  SearchViewController + Model.swift
//  SumDU
//
//  Created by Yura Voevodin on 15.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation

enum State: Int {
    case Favorites
    case Teachers
    case Groups
    case Auditoriums
    
    var name: String {
        switch self {
        case .Favorites: return ""
        case .Teachers: return NSLocalizedString("Teacher", comment: "")
        case .Groups: return NSLocalizedString("Group", comment: "")
        case .Auditoriums: return NSLocalizedString("Auditorium", comment: "")
        }
    }
}

// Section for content table
struct DataSection {
    var letter: Character
    var records: [ListData]
}

struct DataModel {
    var auditoriums: [ListData]
    var groups: [ListData]
    var teachers: [ListData]
    var history: [ListData]
    var currentState: State
    
    func currentData(query: String? = nil) -> [ListData] {
        var data: [ListData] = []
        switch currentState {
        case .Auditoriums: data = auditoriums
        case .Favorites: data = history
        case .Groups: data = groups
        case .Teachers: data = teachers
        }
        if let query = query where query.characters.count > 0 {
            data = data.filter { return $0.name.containsString(query) }
        }
        return data
    }
    
    func currentDataBySections(query: String? = nil) -> [DataSection] {
        var recordsBySection: [DataSection] = []
        let allData = self.currentData(query)
        // Get all unique first letters
        var uniqueCharacters = Set<Character>()
        for item in allData {
            if let first = item.name.characters.first {
                uniqueCharacters.insert(first)
            }
        }
        // Iterate lettres
        for letter in uniqueCharacters.sort() {
            var sectionRecords: [ListData] = []
            for item in allData {
                if letter == item.name.characters.first {
                    sectionRecords.append(item)
                }
            }
            recordsBySection.append(DataSection(letter: letter, records: sectionRecords))
        }
        return recordsBySection
    }
    
    /// Load data from storage
    mutating func updateFromStorage() {
        auditoriums = ListData.loadFromStorage(UserDefaultsKey.Auditoriums.key)
        groups = ListData.loadFromStorage(UserDefaultsKey.Groups.key)
        history = ListData.loadFromStorage(UserDefaultsKey.History.key)
        teachers = ListData.loadFromStorage(UserDefaultsKey.Teachers.key)
    }
    
    /// Send request to server for update model data (asynchronously)
    func updateFromServer(with parser: Parser) {
        parser.sendDataRequest(.Auditorium)
        parser.sendDataRequest(.Teacher)
        parser.sendDataRequest(.Group)
    }
}
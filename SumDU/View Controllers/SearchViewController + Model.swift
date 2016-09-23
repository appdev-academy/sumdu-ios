//
//  SearchViewController + Model.swift
//  SumDU
//
//  Created by Yura Voevodin on 15.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Foundation

enum State: Int {
    case favorites
    case teachers
    case groups
    case auditoriums
    
    var name: String {
        switch self {
        case .favorites: return "Favorites"
        case .teachers: return NSLocalizedString("Teacher", comment: "")
        case .groups: return NSLocalizedString("Group", comment: "")
        case .auditoriums: return NSLocalizedString("Auditorium", comment: "")
        }
    }
}

/// Section for content table
struct DataSection {
    var letter: Character
    var records: [ListData]
}

// MARK: - Data model description

struct DataModel {
    
    /// Text from search
    var searchText: String? = nil {
        didSet {
            self.updateCurrentDataBySections()
        }
    }
    
    /// Search or normal mode
    var searchMode: Bool = false
    
    // Current model state
    var currentState: State {
        didSet {
            self.updateCurrentDataBySections()
        }
    }
    
    // Data for current model state
    var currentData: [DataSection]
    
    var auditoriums: [ListData]
    var groups: [ListData]
    var teachers: [ListData]
    var history: [ListData]
    
    // MARK: - Helpers
    
    /// Filter current data with search text
    fileprivate func filterCurrentData() -> [ListData] {
        var data: [ListData] = []
        switch currentState {
        case .auditoriums: data = auditoriums
        case .favorites: data = history
        case .groups: data = groups
        case .teachers: data = teachers
        }
        if let query = searchText , query.characters.count > 0 {
            data = data.filter { return $0.name.localizedCaseInsensitiveContains(query) }
        }
        return data
    }
    
    /// Update current data and group by sections
    fileprivate mutating func updateCurrentDataBySections() {
        // Clear previous data
        currentData = []
        let allData = self.filterCurrentData()
        // Get all unique first letters
        var uniqueCharacters = Set<Character>()
        for item in allData {
            if let first = item.name.characters.first {
                uniqueCharacters.insert(first)
            }
        }
        // Iterate letters
        let sortedCharacters = uniqueCharacters.sorted { (s1, s2) -> Bool in
            return String(s1).localizedCaseInsensitiveCompare(String(s2)) == .orderedAscending
        }
        for letter in sortedCharacters {
            var sectionRecords: [ListData] = []
            for item in allData {
                if letter == item.name.characters.first {
                    sectionRecords.append(item)
                }
            }
            currentData.append(DataSection(letter: letter, records: sectionRecords))
        }
    }
    
    /// Load data from storage
    mutating func updateFromStorage() {
        auditoriums = ListData.loadFromStorage(UserDefaultsKey.Auditoriums.key)
        groups = ListData.loadFromStorage(UserDefaultsKey.Groups.key)
        history = ListData.loadFromStorage(UserDefaultsKey.History.key)
        teachers = ListData.loadFromStorage(UserDefaultsKey.Teachers.key)
        updateCurrentDataBySections()
    }
    
    /// Send request to server for update model data (asynchronously)
    func updateFromServer(with parser: Parser) {
        parser.sendDataRequest(.Auditorium)
        parser.sendDataRequest(.Teacher)
        parser.sendDataRequest(.Group)
    }
}

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
        case .Favorites: return "Favorites"
        case .Teachers: return NSLocalizedString("Teacher", comment: "")
        case .Groups: return NSLocalizedString("Group", comment: "")
        case .Auditoriums: return NSLocalizedString("Auditorium", comment: "")
        }
    }
}

// MARK: - Data model description

struct DataModel {
    
    /// Text from search
    var searchText: String? {
        didSet {
            self.updateData()
        }
    }
    
    /// Search or normal mode
    var searchMode: Bool = false
    
    // Current model state
    var currentState: State {
        didSet {
            self.updateData()
        }
    }
    
    // Data for current model state
    var current: Dictionary<Character, Array<ListData>>
    var sortedSections = [Character]()
    
    var auditoriums: [ListData]
    var groups: [ListData]
    var teachers: [ListData]
    var history: [ListData]
    
    // MARK: - Helpers
    
    /// Filter current data with search text
    private func filteredData() -> [ListData] {
        var data: [ListData] = []
        switch currentState {
        case .Auditoriums: data = auditoriums
        case .Favorites: data = history
        case .Groups: data = groups
        case .Teachers: data = teachers
        }
        if let query = searchText where query.characters.count > 0 {
            data = data.filter { return $0.name.localizedCaseInsensitiveContainsString(query) }
        }
        return data
    }
    
    /// Update current data and group by sections
    private mutating func updateData() {
        var sections = Dictionary<Character, Array<ListData>>()
        for item in self.filteredData() {
            if let firstLetter = item.name.characters.first {
                if sections.indexForKey(firstLetter) == nil {
                    sections[firstLetter] = [item]
                } else {
                    sections[firstLetter]?.append(item)
                }
            }
        }
        current = sections
        sortedSections = sections.keys.sort { (s1, s2) -> Bool in
            return String(s1).localizedCaseInsensitiveCompare(String(s2)) == .OrderedAscending
        }
    }
    
    /// Load data from storage
    mutating func updateFromStorage() {
        auditoriums = ListData.loadFromStorage(UserDefaultsKey.Auditoriums.key)
        groups = ListData.loadFromStorage(UserDefaultsKey.Groups.key)
        teachers = ListData.loadFromStorage(UserDefaultsKey.Teachers.key)
    }
    
    mutating func updateHistoryFromStorage() {
        history = ListData.loadFromStorage(UserDefaultsKey.History.key)
        updateData()
    }
    
    /// Send request to server for update model data (asynchronously)
    func updateFromServer(with parser: Parser) {
        parser.sendDataRequest(.Auditorium)
        parser.sendDataRequest(.Teacher)
        parser.sendDataRequest(.Group)
    }
}
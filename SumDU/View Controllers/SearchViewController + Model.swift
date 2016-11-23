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
  case groups
  case teachers
  case auditoriums
  
  var name: String {
    switch self {
    case .favorites: return ""
    case .groups: return NSLocalizedString("Group", comment: "")
    case .teachers: return NSLocalizedString("Teacher", comment: "")
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
  
  /// Search or normal mode
  var searchMode: Bool = false
  
  /// Text from search
  var searchText: String? = nil {
    didSet {
      if searchText == nil {
        getSordetData()
      } else {
        sortData()
      }
    }
  }
  
  /// Current model state
  var currentState: State = .favorites {
    didSet {
      if searchMode && searchText != nil {
        sortData()
      } else {
        getSordetData()
      }
    }
  }
  
  // Data for current model state
  var currentData: [DataSection] = []
  
  // All data, not filtered
  var auditoriums: [ListData] = []
  var groups: [ListData] = []
  var teachers: [ListData] = []
  var history: [ListData] = []
  
  // Sections, filtered
  fileprivate var auditoriumsSorted: [DataSection] = []
  fileprivate var groupSorted: [DataSection] = []
  fileprivate var teachersSorted: [DataSection] = []
  fileprivate var historySorted: [DataSection] = []
  
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
    if let query = searchText, query.characters.count > 0 {
      data = data.filter { return $0.name.localizedCaseInsensitiveContains(query) }
    }
    return data
  }
  
  /// Update current data and group by sections from cache
  fileprivate mutating func getSordetData() {
    switch currentState {
    case .auditoriums:
      if auditoriumsSorted.count > 0 {
        currentData = auditoriumsSorted
      } else {
        sortData()
      }
    case .groups:
      if groupSorted.count > 0 {
        currentData = groupSorted
      } else {
        sortData()
      }
    case .teachers:
      if teachersSorted.count > 0 {
        currentData = teachersSorted
      } else {
        sortData()
      }
    case .favorites:
      sortData()
    }
  }
  
  /// Update current data and group by sections
  fileprivate mutating func sortData() {
    var filteredDate: [DataSection] = []
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
      // Append sections
      filteredDate.append(DataSection(letter: letter, records: sectionRecords))
    }
    currentData = filteredDate
    
    // Store filtered data
    if searchText == nil {
      switch currentState {
      case .auditoriums:
        auditoriumsSorted = currentData
      case .favorites:
        historySorted = currentData
      case .groups:
        groupSorted = currentData
      case .teachers:
        teachersSorted = currentData
      }
    }
  }
  
  /// Load data from storage
  mutating func updateFromStorage() {
    auditoriums = ListData.loadFromStorage(UserDefaultsKey.Auditoriums.key)
    groups = ListData.loadFromStorage(UserDefaultsKey.Groups.key)
    history = ListData.loadFromStorage(UserDefaultsKey.History.key)
    teachers = ListData.loadFromStorage(UserDefaultsKey.Teachers.key)
    sortData()
  }
  
  /// Send request to server for update model data (asynchronously)
  func updateFromServer(with parser: Parser) {
    parser.updateListsOfAuditoriumsGroupsAndTeachers()
  }
}

//
//  SearchViewController.swift
//  SumDU
//
//  Created by Yura Voevodin on 11.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import CoreDuck
import DuckDate
import UIKit
import Quack
import SwiftyJSON

/// Main controller with search and table
class SearchViewController: UIViewController {
  
  // MARK: - Properties
  
  /// State of UI
  ///
  /// - showContent: Display content
  /// - emptySearch: Search with empty results
  /// - emptyHistory: Empty history
  enum UIState {
    case showContent
    case emptySearch
    case emptyHistory
  }
  
  // MARK: - Constants
  
  fileprivate let scrollConstraintGroup = ConstraintGroup()
  
  // MARK: - Variables
  
  fileprivate var auditoriums: NSFetchedResultsController<ListObject>!
  fileprivate var teachers: NSFetchedResultsController<ListObject>!
  fileprivate var groups: NSFetchedResultsController<ListObject>!
  var history: NSFetchedResultsController<ListObject>!
  
  fileprivate var tableViewContentInset = UIEdgeInsets.zero
  fileprivate var stateOfUI: UIState = .showContent {
    didSet {
      switch stateOfUI {
      case .emptyHistory:
        // Hide table and show empty history
        tableView.isHidden = true
        emptyHistoryView.isHidden = false
        notFoundLabel.isHidden = true
      case .showContent:
        // Hide empty history and show table
        emptyHistoryView.isHidden = true
        tableView.isHidden = false
        notFoundLabel.isHidden = true
      case .emptySearch:
        // Hide table and show "not found" label
        tableView.isHidden = true
        emptyHistoryView.isHidden = true
        notFoundLabel.isHidden = false
      }
    }
  }
  
  /// Save type of displayed content
  fileprivate var contentType: ContentType = .history {
    didSet {
      updateUI()
    }
  }
  
  /// State of search
  fileprivate var isSearching = false {
    didSet {
      if isSearching {
        // Highlight
        updateUI()
      } else {
        // Clear search text if canceled
        searchText = nil
      }
    }
  }
  
  /// Text from search field
  fileprivate var searchText: String? = nil {
    didSet {
      // Make search
      fetchData()
      updateUI()
    }
  }
  
  fileprivate var selectedObjectID: Int64?
  
  // MARK: - UI objects
  
  fileprivate let searchBarView = SearchBarView()
  fileprivate var menuCollectionView: UICollectionView!
  fileprivate let scrollLineView = UIView()
  fileprivate let scrollingIndicatorView = UIView()
  fileprivate let notFoundLabel = UILabel()
  fileprivate let tableView = UITableView()
  fileprivate let emptyHistoryView = EmptyHistoryView()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    registerForNotifications()
    
    initialSetup()
    
    updateUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    updateMenuScrollIndicator()
    
    // Select menu item
    let indexPath = IndexPath(item: contentType.rawValue, section: 0)
    menuCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
  }
  
  deinit {
    deregisterFromNotifications()
  }
  
  // MARK: - Helpers
  
  /// Add UI objects and set constraints
  fileprivate func initialSetup() {
    // Background
    view.backgroundColor = UIColor.white
    
    // Search bar
    searchBarView.delegate = self
    view.addSubview(searchBarView)
    constrain(searchBarView, view) {
      searchBarView, superview in
      
      searchBarView.top == superview.top + 30.0
      searchBarView.leading == superview.leading + 14.0
      searchBarView.trailing == superview.trailing
      searchBarView.height == SearchBarView.viewHeight
    }
    
    // Menu
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    menuCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
    menuCollectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: MenuCollectionViewCell.reuseIdentifier)
    menuCollectionView.register(MenuImageCollectionViewCell.self, forCellWithReuseIdentifier: MenuImageCollectionViewCell.reuseIdentifier)
    menuCollectionView.delegate = self
    menuCollectionView.dataSource = self
    menuCollectionView.showsVerticalScrollIndicator = false
    menuCollectionView.showsHorizontalScrollIndicator = false
    menuCollectionView.isPagingEnabled = true
    menuCollectionView.backgroundColor = UIColor.white
    view.addSubview(menuCollectionView)
    constrain(searchBarView, menuCollectionView, view) {
      searchBarView, menuCollectionView, superview in
      
      menuCollectionView.top == searchBarView.bottom
      menuCollectionView.leading == superview.leading
      menuCollectionView.trailing == superview.trailing
      menuCollectionView.height == 62.0
    }
    
    // Scroll line
    scrollLineView.backgroundColor = Color.separator
    view.addSubview(scrollLineView)
    constrain(scrollLineView, menuCollectionView, view) {
      scrollLineView, menuCollectionView, superview in
      
      scrollLineView.top == menuCollectionView.bottom
      scrollLineView.leading == superview.leading
      scrollLineView.trailing == superview.trailing
      scrollLineView.height == 1.0
    }
    
    // Scrolling indicator
    scrollingIndicatorView.backgroundColor = Color.textBlack
    view.addSubview(scrollingIndicatorView)
    constrain(scrollingIndicatorView, scrollLineView, view) {
      scrollingIndicatorView, scrollLineView, superview in
      
      scrollingIndicatorView.bottom == scrollLineView.bottom
      scrollingIndicatorView.height == 2.0
    }
    
    // Content table
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
    tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
    tableView.separatorStyle = .none
    view.addSubview(tableView)
    constrain(tableView, scrollLineView, view) {
      contentTableView, scrollLineView, superview in
      
      contentTableView.top == scrollLineView.bottom
      contentTableView.leading == superview.leading
      contentTableView.trailing == superview.trailing
      contentTableView.bottom == superview.bottom
    }
    
    // Not found
    notFoundLabel.isHidden = true
    notFoundLabel.text = NSLocalizedString("No data found", comment: "")
    notFoundLabel.font = Font.named(.helveticaNeueMedium, size: 20.0)
    notFoundLabel.textColor = Color.textNormal
    notFoundLabel.textAlignment = .center
    view.addSubview(notFoundLabel)
    constrain(notFoundLabel, scrollLineView, view) {
      notFoundLabel, scrollLineView, superview in
      
      notFoundLabel.top == scrollLineView.top + 66.0
      notFoundLabel.leading == superview.leading + 14.0
      notFoundLabel.trailing == superview.trailing - 14.0
    }
    
    // Empty history
    emptyHistoryView.isHidden = true
    view.addSubview(emptyHistoryView)
    constrain(tableView, emptyHistoryView) {
      contentTableView, emptyHistoryView in
      
      emptyHistoryView.edges == contentTableView.edges
    }
  }
  
  func fetchData() {
    auditoriums = ListObject.fetch(search: searchText, type: .auditoriums, delegate: self)
    teachers = ListObject.fetch(search: searchText, type: .teachers, delegate: self)
    groups = ListObject.fetch(search: searchText, type: .groups, delegate: self)
    history = ListObject.fetch(search: searchText, type: .history, delegate: self)
  }
  
  /// Show matching pattern
  fileprivate func highlightSearchResults(_ searchString: String, resultString: String) -> NSMutableAttributedString {
    
    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: resultString)
    let pattern = searchString
    let range: NSRange = NSMakeRange(0, resultString.characters.count)
    
    let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    
    regex?.enumerateMatches(in: resultString, options: NSRegularExpression.MatchingOptions(), range: range) {
      (textCheckingResult, matchingFlags, stop) -> Void in
      
      if let subRange = textCheckingResult?.range {
        attributedString.addAttribute(NSForegroundColorAttributeName, value: Color.textNormal, range: subRange)
      }
    }
    return attributedString
  }
  
  /// Populate cell from the NSManagedObject instance
  ///
  /// - Parameters:
  ///   - cell: UITableViewCell object from table
  ///   - indexPath: IndexPath
  fileprivate func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
    guard let cell = cell as? SearchTableViewCell else { return }
    
    let name: String
    let object: ListObject
    switch contentType {
    case .auditoriums:
      object = auditoriums.object(at: indexPath)
      name = object.name
    case .history:
      object = history.object(at: indexPath)
      name = object.name
    case .groups:
      object = groups.object(at: indexPath)
      name = object.name
    case .teachers:
      object = teachers.object(at: indexPath)
      name = object.name
    }
    
    if isSearching {
      // Highlight search results
      cell.label.textColor = Color.textLight
      if let searchingText = searchText {
        cell.label.attributedText = highlightSearchResults(searchingText, resultString: name)
      } else {
        cell.label.text = name
      }
    } else {
      // Show normal text
      cell.label.text = name
      cell.label.textColor = Color.textNormal
    }
    
    // Select row
    if let selectedID = selectedObjectID, object.id == selectedID {
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
  }
  
  /// Populate header with data
  ///
  /// - Parameters:
  ///   - headerView: UITableViewHeaderFooterView for section
  ///   - section: index of section
  fileprivate func configureHeader(_ headerView: UITableViewHeaderFooterView?, section: Int) {
    guard let header = headerView as? SectionHeaderView else { return }
    
    let text: String
    switch contentType {
    case .auditoriums:
      text = auditoriums.sections?[section].name ?? ""
    case .history:
      text = history.sections?[section].name ?? ""
    case .groups:
      text = groups.sections?[section].name ?? ""
    case .teachers:
      text = teachers.sections?[section].name ?? ""
    }
    
    header.dateLabel.text = text
  }
  
  /// Display right UI depending of content
  fileprivate func updateUI() {
    // Update state of UI
    switch contentType {
    case .auditoriums:
      stateOfUI = auditoriums.fetchedObjects?.count == 0 ? .emptySearch : .showContent
    case .history:
      stateOfUI = history.fetchedObjects?.count == 0 ? .emptyHistory : .showContent
    case .groups:
      stateOfUI = groups.fetchedObjects?.count == 0 ? .emptySearch : .showContent
    case .teachers:
      stateOfUI = teachers.fetchedObjects?.count == 0 ? .emptySearch : .showContent
    }
    tableView.reloadData()
    updateTableContentInset()
  }
  
  fileprivate func labelWidth(_ text: String) -> CGFloat {
    let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: MenuCollectionViewCell.cellHeight)
    let attributes = [NSFontAttributeName: Font.named(.helveticaNeueMedium, size: 17.0)]
    return text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.width
  }
  
  /// Calculate spacing between items in menu
  fileprivate func interItemSpacing() -> CGFloat {
    let screenWidth = view.bounds.width
    var spacing = screenWidth
    spacing -= MenuImageCollectionViewCell.historyImageSize.width
    spacing -= labelWidth(ContentType.teachers.name)
    spacing -= labelWidth(ContentType.auditoriums.name)
    spacing -= labelWidth(ContentType.groups.name)
    return spacing/4.0
  }
  
  /// Update scroll indicator in menu
  fileprivate func updateMenuScrollIndicator() {
    let spacing = interItemSpacing()
    var leading: CGFloat = 0.0
    var width: CGFloat = labelWidth(contentType.name)
    let historyImageWidth = MenuImageCollectionViewCell.historyImageSize.width
    switch contentType {
      
    case .history:
      leading = spacing/2
      width = historyImageWidth
      
    case .groups:
      leading = spacing + spacing/2
      leading += historyImageWidth
      
    case .teachers:
      leading = spacing*2 + spacing/2
      leading += historyImageWidth
      leading += labelWidth(ContentType.groups.name)
      
    case .auditoriums:
      leading = spacing*3 + spacing/2
      leading += historyImageWidth
      leading += labelWidth(ContentType.teachers.name)
      leading += labelWidth(ContentType.groups.name)
    }
    constrain(scrollingIndicatorView, view, replace: scrollConstraintGroup) { scrollingIndicatorView, superview in
      scrollingIndicatorView.leading == superview.leading + leading
      scrollingIndicatorView.width == width
    }
  }
  
  fileprivate func updateTableContentInset() {
    tableView.contentInset = tableViewContentInset
    tableView.scrollIndicatorInsets = tableViewContentInset
  }
  
  /// Delete related to the listObject records
  ///
  /// - Parameter listObject: ListObject
  fileprivate func delete(_ listObject: ListObject) {
    NSManagedObjectContext.saveWithBlock({
      localContext in
      
      if let object = listObject.inContext(localContext) as? ListObject {
        for scheduleRecords in object.scheduleRecords {
          if let record = scheduleRecords as? ScheduleRecord {
            localContext.delete(record)
          }
        }
      }

    }, completion: {
      success in
      
      if success {
        // Clear ScheduleViewController if deleted row is selected
        if UIDevice.current.userInterfaceIdiom == .pad, self.selectedObjectID == listObject.id {
          self.selectedObjectID = nil
          if let scheduleViewController = self.splitViewController?.viewControllers.last as? ScheduleViewController {
            scheduleViewController.clearSchedule()
          }
        }
      } else {
        self.showAlert(title: NSLocalizedString("Deleting error", comment: "Alert title"), message: nil)
      }
    })
  }
  
  // MARK: - Notifications
  
  fileprivate func registerForNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  fileprivate func deregisterFromNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  func keyboardWillShow(_ notification: Notification) {
    guard let userInfo: NSDictionary = notification.userInfo as NSDictionary?,
      let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as? NSValue else {
        return
    }
    let keyboardHeight = keyboardFrame.cgRectValue.size.height
    tableViewContentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight,  0.0);
    updateTableContentInset()
  }
  
  func keyboardWillHide(_ notification: Notification) {
    tableViewContentInset = UIEdgeInsets.zero
    updateTableContentInset()
  }
}

// MARK: - SearchBarViewDelegate

extension SearchViewController: SearchBarViewDelegate {
  
  func refreshContent(searchBarView view: SearchBarView) {
    NetworkingManager.updateListsOfAuditoriumsGroupsAndTeachers()
  }
  
  func searchBarView(searchBarView view: SearchBarView, searchWithText text: String?) {
    tableView.setContentOffset(CGPoint.zero, animated: false)
    
    searchText = text
  }
  
  func searchBarView(searchBarView view: SearchBarView, searchMode: Bool) {
    tableView.setContentOffset(CGPoint.zero, animated: false)
    
    if searchMode != isSearching {
      isSearching = searchMode
    }
  }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // Get new type
    guard let newType = ContentType(rawValue: indexPath.row) else { return }
    
    // If user select other state
    guard contentType != newType else { return }
    
    // Stop scroll of table
    tableView.setContentOffset(CGPoint.zero, animated: false)
    
    // Update type
    contentType = newType
    
    // Update menu
    updateMenuScrollIndicator()
    UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
  }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.row != 0, let segment = ContentType(rawValue: indexPath.row) {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.reuseIdentifier, for: indexPath) as! MenuCollectionViewCell
      cell.update(withTitle: segment.name)
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuImageCollectionViewCell.reuseIdentifier, for: indexPath) as! MenuImageCollectionViewCell
      return cell
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    guard let type = ContentType(rawValue: indexPath.row) else {
      return CGSize(width: 0.0, height: 0.0)
    }
    
    // Menu
    let spacing = interItemSpacing()
    let cellHeight = MenuCollectionViewCell.cellHeight
    switch type {
    case .history:
      return CGSize(width: MenuImageCollectionViewCell.historyImageSize.width + spacing, height: cellHeight)
    case .auditoriums, .groups, .teachers:
      return CGSize(width: labelWidth(type.name) + spacing, height: cellHeight)
    }
  }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    let numberOfSections: Int
    switch contentType {
    case .auditoriums:
      numberOfSections = auditoriums.sections?.count ?? 0
    case .history:
      numberOfSections = history.sections?.count ?? 0
    case .groups:
      numberOfSections = groups.sections?.count ?? 0
    case .teachers:
      numberOfSections = teachers.sections?.count ?? 0
    }
    return numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let numberOfRows: Int
    switch contentType {
    case .auditoriums:
      numberOfRows = auditoriums.sections?[section].numberOfObjects ?? 0
    case .history:
      numberOfRows = history.sections?[section].numberOfObjects ?? 0
    case .groups:
      numberOfRows = groups.sections?[section].numberOfObjects ?? 0
    case .teachers:
      numberOfRows = teachers.sections?[section].numberOfObjects ?? 0
    }
    return numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier, for: indexPath)
    
    configureCell(cell, indexPath: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    switch contentType {
    case .auditoriums, .groups, .teachers:
      return false
    case .history:
      return true
    }
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      switch contentType {
      case .history:
        let listObject = history.object(at: indexPath)
        delete(listObject)
      case .auditoriums, .groups, .teachers:
        break
      }
    }
  }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return SearchTableViewCell.cellHeight
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SectionHeaderView.viewHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.reuseIdentifier)
    
    configureHeader(headerView, section: section)
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let listObject: ListObject
    switch contentType {
    case .auditoriums:
      listObject = auditoriums.object(at: indexPath)
    case .groups:
      listObject = groups.object(at: indexPath)
    case .history:
      listObject = history.object(at: indexPath)
    case .teachers:
      listObject = teachers.object(at: indexPath)
    }
    // Check if this row already selected
    guard selectedObjectID != listObject.id else { return }
    
    selectedObjectID = listObject.id

    // For iPad
    if UIDevice.current.userInterfaceIdiom == .pad {
      // Get Schedule controller
      if let scheduleViewController = splitViewController?.viewControllers.last as? ScheduleViewController {
        scheduleViewController.fetchSchedule(for: listObject)
        
        // Send request
        let networkingManager = NetworkingManager()
        networkingManager.delegate = scheduleViewController
        networkingManager.scheduleRequest(for: listObject)
      }
      
      // For iPhone
    } else if UIDevice.current.userInterfaceIdiom == .phone {
      let scheduleViewController = ScheduleViewController()
      scheduleViewController.fetchSchedule(for: listObject)
      
      // Send request
      let networkingManager = NetworkingManager()
      networkingManager.delegate = scheduleViewController
      networkingManager.scheduleRequest(for: listObject)
      
      // Push controller
      navigationController?.pushViewController(scheduleViewController, animated: true)
    }
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SearchViewController: NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    updateUI()
  }
}

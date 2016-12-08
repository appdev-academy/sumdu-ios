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
import SwiftyJSON

/// Type of content to display
enum ContentType: Int {
  case favorites
  case groups
  case teachers
  case auditoriums
  
  var name: String {
    switch self {
    case .favorites:
      return ""
    case .groups:
      return NSLocalizedString("Group", comment: "")
    case .teachers:
      return NSLocalizedString("Teacher", comment: "")
    case .auditoriums:
      return NSLocalizedString("Auditorium", comment: "")
    }
  }
}

class SearchViewController: UIViewController {
  
  // MARK: - Properties
  
  /// State of UI
  ///
  /// - showContent: Display content
  /// - emptySearch: Search with empty results
  /// - emptyHistory: Empty hisotry
  enum UIState {
    case showContent
    case emptySearch
    case emptyHistory
  }
  
  // MARK: - Constants
  
  fileprivate let scrollConstraintGroup = ConstraintGroup()
  
  // MARK: - Variables
  
  fileprivate var auditoriums: NSFetchedResultsController<Auditorium>!
  fileprivate var teachers: NSFetchedResultsController<Teacher>!
  fileprivate var groups: NSFetchedResultsController<Group>!
  
  fileprivate var tableViewContentInset = UIEdgeInsets.zero
  fileprivate var stateOfUI: UIState = .showContent {
    didSet {
      switch stateOfUI {
      case .emptyHistory:
        // Hide table and show empty history
        contentTableView.isHidden = true
        emptyHistoryView.isHidden = false
        notFoundLabel.isHidden = true
      case .showContent:
        // Hide empty history and show table
        emptyHistoryView.isHidden = true
        contentTableView.isHidden = false
        notFoundLabel.isHidden = true
      case .emptySearch:
        // Hide table and show "not found" label
        contentTableView.isHidden = true
        emptyHistoryView.isHidden = true
        notFoundLabel.isHidden = false
      }
    }
  }
  
  /// Save type of displayed content
  fileprivate var contentType: ContentType = .favorites {
    didSet {
      updateUI()
    }
  }
  
  /// Parser for working with server
  fileprivate var parser = Parser()
  
  /// Data model
  fileprivate var model = DataModel()
  
  // MARK: - UI objects
  
  fileprivate let searchBarView = SearchBarView()
  fileprivate var menuCollectionView: UICollectionView!
  fileprivate let scrollLineView = UIView()
  fileprivate let scrollingIndicatorView = UIView()
  fileprivate let notFoundLabel = UILabel()
  fileprivate let contentTableView = UITableView()
  fileprivate let emptyHistoryView = EmptyHistoryView()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    registerForNotifications()
    
    initialSetup()
    
    if UIDevice.current.userInterfaceIdiom == .pad {
//      if let firstItem = model.history.first, let scheduleViewController = splitViewController?.viewControllers.last as? ScheduleViewController {
        //        scheduleViewController.updateFromStorage(withItem: firstItem)
//      }
    }
    
    updateUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    updateMenuScrollIndicator()
    
    // Select menu item
    let indexPath = IndexPath(item: model.currentState.rawValue, section: 0)
    menuCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
  }
  
  deinit {
    deregisterFromNotifications()
  }
  
  // MARK: - Helpers
  
  func fetchData() {
    auditoriums = Auditorium.fetchAll(sortedBy: "name", ascending: true, delegate: self)
    teachers = Teacher.fetchAll(sortedBy: "name", ascending: true, delegate: self)
    groups = Group.fetchAll(sortedBy: "name", ascending: true, delegate: self)
  }
  
  /// Populate cell from the NSManagedObject instance
  ///
  /// - Parameters:
  ///   - cell: UITableViewCell object from table
  ///   - indexPath: IndexPath
  fileprivate func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
    guard let cell = cell as? SearchTableViewCell else { return }
    let name: String
    switch contentType {
    case .auditoriums:
      name = auditoriums.object(at: indexPath).name
    case .favorites:
      name = ""
    case .groups:
      name = groups.object(at: indexPath).name
    case .teachers:
      name = teachers.object(at: indexPath).name
    }
    cell.label.text = name
  }
  
  /// Display right UI depending of content
  fileprivate func updateUI() {
    // Update state of UI
    switch contentType {
    case .auditoriums:
      stateOfUI = auditoriums.fetchedObjects?.count == 0 ? .emptySearch : .showContent
    case .favorites:
      stateOfUI = .emptyHistory
    case .groups:
      stateOfUI = groups.fetchedObjects?.count == 0 ? .emptySearch : .showContent
    case .teachers:
      stateOfUI = teachers.fetchedObjects?.count == 0 ? .emptySearch : .showContent
    }
    
    // Reload table
    if stateOfUI == .showContent {
      contentTableView.reloadData()
      updateTableContentInset()
    }
  }
  
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
    contentTableView.delegate = self
    contentTableView.dataSource = self
    contentTableView.register(ScheduleSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: ScheduleSectionHeaderView.reuseIdentifier)
    contentTableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
    contentTableView.separatorStyle = .none
    view.addSubview(contentTableView)
    constrain(contentTableView, scrollLineView, view) {
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
    constrain(contentTableView, emptyHistoryView) {
      contentTableView, emptyHistoryView in
      
      emptyHistoryView.edges == contentTableView.edges
    }
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
      
    case .favorites:
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
    contentTableView.contentInset = tableViewContentInset
    contentTableView.scrollIndicatorInsets = tableViewContentInset
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
    // Stop scroll of table
    contentTableView.setContentOffset(CGPoint.zero, animated: false)
    
    if model.searchMode {
      // Update search text
      model.searchText = text
      updateUI()
    }
  }
  
  func searchBarView(searchBarView view: SearchBarView, searchMode: Bool) {
    // Stop scroll of table
    contentTableView.setContentOffset(CGPoint.zero, animated: false)
    
    // Clear search text if canceled
    if !searchMode {
      model.searchText = nil
    }
    
    if searchMode != model.searchMode {
      // Update search mode
      model.searchMode = searchMode
      updateUI()
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
    
    // Scroll to the top of table
    contentTableView.setContentOffset(CGPoint.zero, animated: false)
    
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
    case .favorites:
      return CGSize(width: MenuImageCollectionViewCell.historyImageSize.width + spacing, height: cellHeight)
    case .auditoriums, .groups, .teachers:
      return CGSize(width: labelWidth(type.name) + spacing, height: cellHeight)
    }
  }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  
  //  func numberOfSections(in tableView: UITableView) -> Int {
  //    return model.currentData.count
  //  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let numberOfRows: Int
    switch contentType {
    case .auditoriums:
      numberOfRows = auditoriums.sections?[section].numberOfObjects ?? 0
    case .favorites:
      numberOfRows = 0
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
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return SearchTableViewCell.cellHeight
  }
  
//  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//    return ScheduleSectionHeaderView.viewHeight
//  }
//  
//  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ScheduleSectionHeaderView.reuseIdentifier) as! ScheduleSectionHeaderView
//    if model.currentData.count > 0 {
//      headerView.dateLabel.text = String(model.currentData[section].letter)
//    }
//    return headerView
//  }
  
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    
//    let dataItem = model.currentData[indexPath.section].records[indexPath.row]
//    
//    // For iPad
//    if UIDevice.current.userInterfaceIdiom == .pad {
//      // Get Schedule controller
//      if let scheduleViewController = splitViewController?.viewControllers.last as? ScheduleViewController {
//        // Update data
//        if model.currentState == .favorites {
//          scheduleViewController.updateFromStorage(withItem: dataItem)
//        } else {
//          scheduleViewController.updateFromServer(withItem: dataItem)
//        }
//      }
//      
//      // For iPhone
//    } else if UIDevice.current.userInterfaceIdiom == .phone {
//      let scheduleViewController = ScheduleViewController()
//      if model.currentState == .favorites {
//        scheduleViewController.updateFromStorage(withItem: dataItem)
//      } else {
//        scheduleViewController.updateFromServer(withItem: dataItem)
//      }
//      navigationController?.pushViewController(scheduleViewController, animated: true)
//    }
//    
//    // Remember selected item
//    while model.history.count > 50 { model.history.removeFirst() }
//    let historyItems = model.history.filter { $0.name == dataItem.name }
//    if historyItems.count == 0 { model.history.append(dataItem) }
//    ListData.saveToStorage(model.history, forKey: UserDefaultsKey.History.key)
//  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SearchViewController: NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    // Reload table
    if stateOfUI == .showContent {
      contentTableView.reloadData()
      updateTableContentInset()
    }
  }
}
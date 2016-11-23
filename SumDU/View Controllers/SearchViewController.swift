//
//  SearchViewController.swift
//  SumDU
//
//  Created by Yura Voevodin on 11.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit
import SwiftyJSON

class SearchViewController: UIViewController {
  
  // MARK: - Properties
  
  enum ContentState {
    case showContent
    case emptySearch
    case emptyHistory
  }
  
  // MARK: - Constants
  
  fileprivate let scrollConstraintGroup = ConstraintGroup()
  
  // MARK: - Variables
  
  fileprivate var tableViewContentInset = UIEdgeInsets.zero
  fileprivate var contentState: ContentState = .showContent {
    didSet {
      switch contentState {
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
    
    // UI
    initialSetup()
    
    // Data
    parser.dataListDelegate = self
    model.updateFromStorage()
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      if let firstItem = model.history.first, let scheduleViewController = splitViewController?.viewControllers.last as? ScheduleViewController {
        scheduleViewController.updateFromStorage(withItem: firstItem)
      }
    }
    
    updateContent()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Check if lists of Teachers, Groups and Auditoriums was updated more than 3 days ago
    let lastUpdatedDate = UserDefaults.standard.object(forKey: UserDefaultsKey.LastUpdatedAtDate.key) as? Date
    if (lastUpdatedDate == nil) || (lastUpdatedDate != nil && lastUpdatedDate!.compare(Date().dateBySubtractingDays(3)) == .orderedAscending) {
      model.updateFromServer(with: parser)
    }
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
  
  fileprivate func updateContent() {
    if model.currentData.count == 0 && model.searchMode {
      contentState = .emptySearch
    } else if model.currentData.count == 0 && model.currentState == .favorites {
      contentState = .emptyHistory
    } else {
      contentState = .showContent
    }
    
    // Reload table
    if contentState == .showContent {
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
    spacing -= labelWidth(State.teachers.name)
    spacing -= labelWidth(State.auditoriums.name)
    spacing -= labelWidth(State.groups.name)
    return spacing/4.0
  }
  
  /// Update scroll indicator in menu
  fileprivate func updateMenuScrollIndicator() {
    let spacing = interItemSpacing()
    var leading: CGFloat = 0.0
    var width: CGFloat = labelWidth(model.currentState.name)
    let historyImageWidth = MenuImageCollectionViewCell.historyImageSize.width
    switch model.currentState {
      
    case .favorites:
      leading = spacing/2
      width = historyImageWidth
      
    case .groups:
      leading = spacing + spacing/2
      leading += historyImageWidth
      
    case .teachers:
      leading = spacing*2 + spacing/2
      leading += historyImageWidth
      leading += labelWidth(State.groups.name)
      
    case .auditoriums:
      leading = spacing*3 + spacing/2
      leading += historyImageWidth
      leading += labelWidth(State.teachers.name)
      leading += labelWidth(State.groups.name)
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
    model.updateFromServer(with: parser)
  }
  
  func searchBarView(searchBarView view: SearchBarView, searchWithText text: String?) {
    // Stop scroll of table
    contentTableView.setContentOffset(CGPoint.zero, animated: false)
    
    if model.searchMode {
      // Update search text
      model.searchText = text
      updateContent()
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
      updateContent()
    }
  }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    // Get new state
    guard let newState = State(rawValue: indexPath.row) else {
      return
    }
    
    // If user select other state
    guard model.currentState != newState else {
      return
    }
    
    // Scroll to the top of table
    contentTableView.setContentOffset(CGPoint.zero, animated: false)
    
    // Update state
    model.currentState = newState
    updateContent()
    
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
    
    if indexPath.row != 0, let segment = State(rawValue: indexPath.row) {
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
    
    guard let type = State(rawValue: indexPath.row) else {
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

// MARK: - ParserDataListDelegate

extension SearchViewController: ParserDataListDelegate {
  internal func requesSuccess(auditoriums: [ListData], groups: [ListData], teachers: [ListData]) {
    
    // Update Auditoriums
    model.auditoriums = auditoriums
    ListData.saveToStorage(model.auditoriums, forKey: UserDefaultsKey.Auditoriums.key)
    
    // Update Groups
    model.groups = groups
    ListData.saveToStorage(model.groups, forKey: UserDefaultsKey.Groups.key)
    
    // Update Teachers
    model.teachers = teachers
    ListData.saveToStorage(model.teachers, forKey: UserDefaultsKey.Teachers.key)
    
    updateContent()
  }
  
  func requestError(_ parser: Parser, localizedError error: String?) {
    if UIApplication.shared.isNetworkActivityIndicatorVisible {
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // Create alert
    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title in alerts"), style: .default, handler: nil))
    
    // Present alert
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return model.currentData.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if model.currentData.count > 0 {
      return model.currentData[section].records.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier, for: indexPath) as! SearchTableViewCell
    
    if model.currentData.count > 0 {
      cell.update(with: model.currentData[indexPath.section].records[indexPath.row], search: model.searchMode, searchingText: model.searchText)
    }
    return cell
  }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return SearchTableViewCell.cellHeight
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return ScheduleSectionHeaderView.viewHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ScheduleSectionHeaderView.reuseIdentifier) as! ScheduleSectionHeaderView
    if model.currentData.count > 0 {
      headerView.dateLabel.text = String(model.currentData[section].letter)
    }
    return headerView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let dataItem = model.currentData[indexPath.section].records[indexPath.row]
    
    // For iPad
    if UIDevice.current.userInterfaceIdiom == .pad {
      // Get Schedule controller
      if let scheduleViewController = splitViewController?.viewControllers.last as? ScheduleViewController {
        // Update data
        if model.currentState == .favorites {
          scheduleViewController.updateFromStorage(withItem: dataItem)
        } else {
          scheduleViewController.updateFromServer(withItem: dataItem)
        }
      }
      
      // For iPhone
    } else if UIDevice.current.userInterfaceIdiom == .phone {
      let scheduleViewController = ScheduleViewController()
      if model.currentState == .favorites {
        scheduleViewController.updateFromStorage(withItem: dataItem)
      } else {
        scheduleViewController.updateFromServer(withItem: dataItem)
      }
      navigationController?.pushViewController(scheduleViewController, animated: true)
    }
    
    // Remember selected item
    while model.history.count > 50 { model.history.removeFirst() }
    let historyItems = model.history.filter { $0.name == dataItem.name }
    if historyItems.count == 0 { model.history.append(dataItem) }
    ListData.saveToStorage(model.history, forKey: UserDefaultsKey.History.key)
  }
}

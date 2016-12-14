//
//  ScheduleViewController.swift
//  SumDU
//
//  Created by Yura Voevodin on 20.12.15.
//  Copyright © 2015 App Dev Academy. All rights reserved.
//

import Cartography
import CoreDuck
import UIKit

class ScheduleViewController: UIViewController {
  
  // MARK: - Variables
  
  /// URL for add schedule events to calendar
  fileprivate var calendarURL: URL?
  fileprivate var listObject: ListObject?
  fileprivate var schedule: NSFetchedResultsController<ScheduleRecord>?
  
  // MARK: - UI objects
  
  // Navigation bar
  fileprivate let backButton = BackButton()
  fileprivate let shareButton = ShareButton()
  fileprivate let refreshButton = RefreshButton()
  
  // Content
  fileprivate let titleLabel = UILabel()
  fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  fileprivate let tableView = UITableView()
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initialSetup()
  }
  
  // MARK: - Helpers
  
  fileprivate func initialSetup() {
    view.backgroundColor = UIColor.white
    
    let topMargin: CGFloat = 24.0
    let leadingMargin: CGFloat = 14.0
    let trailingMargin: CGFloat = 6.0
    
    // Back
    backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
    view.addSubview(backButton)
    constrain(backButton, view) {
      backButton, superview in
      
      backButton.top == superview.top + topMargin
      backButton.leading == superview.leading + leadingMargin
      backButton.height == BackButton.buttonSize.height
      backButton.width == BackButton.buttonSize.width
    }
    if UIDevice.current.userInterfaceIdiom == .pad {
      backButton.setImage(nil, for: .normal)
      backButton.setImage(nil, for: .highlighted)
    }
    // Refresh
    refreshButton.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
    view.addSubview(refreshButton)
    constrain(refreshButton, view) {
      refreshButton, superview in
      
      refreshButton.top == superview.top + topMargin
      refreshButton.trailing == superview.trailing - trailingMargin
      refreshButton.height == RefreshButton.buttonSize.height
      refreshButton.width == RefreshButton.buttonSize.width
    }
    // Share
    shareButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
    view.addSubview(shareButton)
    constrain(shareButton, refreshButton, view) {
      shareButton, refreshButton, superview in
      
      shareButton.top == superview.top + topMargin
      shareButton.trailing == refreshButton.leading - 2.0
      shareButton.height == ShareButton.buttonSize.height
      shareButton.width == ShareButton.buttonSize.width
    }
    // Title
    titleLabel.font = Font.named(.helveticaNeueMedium, size: 26.0)
    titleLabel.textColor = Color.textBlack
    titleLabel.numberOfLines = 0
    view.addSubview(titleLabel)
    constrain(titleLabel, backButton, view) {
      titleLabel, backButton, superview in
      
      titleLabel.top == backButton.bottom + 5.0
      titleLabel.leading == superview.leading + leadingMargin
      titleLabel.trailing == superview.trailing - trailingMargin
    }
    // Schedule table
    tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
    tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    view.addSubview(tableView)
    constrain(tableView, titleLabel, view) {
      tableView, titleLabel, superview in
      
      tableView.top == titleLabel.bottom + 10.0
      tableView.leading == superview.leading
      tableView.trailing == superview.trailing
      tableView.bottom == superview.bottom
    }
    
    // Indicator
    view.addSubview(activityIndicator)
    constrain(activityIndicator, view) { activityIndicatorView, superview in
      activityIndicatorView.center == superview.center
    }
  }
  
  /// Populate header with data
  ///
  /// - Parameters:
  ///   - headerView: UITableViewHeaderFooterView for section
  ///   - section: index of section
  fileprivate func configureHeader(_ headerView: UITableViewHeaderFooterView?, section: Int) {
    guard let header = headerView as? SectionHeaderView else { return }
    
    header.dateLabel.text = schedule?.sections?[section].name ?? ""
    
    if let firstObject = schedule?.sections?[section].objects?.first as? ScheduleRecord {
      header.dayLabel.text = firstObject.dayString
    }
  }
  
  /// Populate cell from the NSManagedObject instance
  ///
  /// - Parameters:
  ///   - cell: UITableViewCell object from table
  ///   - indexPath: IndexPath
  fileprivate func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
    guard let cell = cell as? ScheduleTableViewCell else { return }
    guard let record = schedule?.object(at: indexPath) else { return }
   
    var name = record.name
    if record.type.characters.count > 0 { name += " (" + record.type + ")" }
    cell.nameLabel.text = name
    
    cell.timeLabel.text = record.time
    cell.auditoriumLabel.text = record.auditorium
    cell.teacherLabel.text = record.teacher
  }
  
  // MARK: - Actions
  
  /// Fetch data about schedule for ListObject
  ///
  /// - Parameter listObject: ListObject
  func fetchSchedule(for listObject: ListObject) {
    self.listObject = listObject
    schedule = ScheduleRecord.fetch(for: listObject, delegate: self)
    tableView.reloadData()
    
    titleLabel.text = listObject.name
  }
  
  /// Clear data about schedule
  func clearSchedule() {
    listObject = nil
    schedule = nil
    tableView.reloadData()
    titleLabel.text = nil
  }
  
  /// Go back to the SearchViewController
  func backButtonPressed() {
    if UIDevice.current.userInterfaceIdiom == .phone {
      let _ = navigationController?.popViewController(animated: true)
    }
  }
  
  /// Refresh schedule table
  func refreshButtonPressed() {
    guard let listObject = listObject else { return }
    
    // Make request again
    let networkingManager = NetworkingManager()
    networkingManager.delegate = self
    networkingManager.scheduleRequest(for: listObject)
  }
  
  /// Share schedule
  func shareButtonPressed() {
    if let listObject = listObject, let url = NetworkingManager.calendarRequest(for: listObject) {
      UIApplication.shared.openURL(url)
    }
  }
  
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return ScheduleTableViewCell.cellHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.reuseIdentifier)
    
    configureHeader(headerView, section: section)
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SectionHeaderView.viewHeight
  }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return schedule?.sections?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return schedule?.sections?[section].numberOfObjects ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath)
    
    configureCell(cell, indexPath: indexPath)
    
    return cell
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ScheduleViewController: NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.reloadData()
  }
}

// MARK: - NetworkingManagerDelegate

extension ScheduleViewController: NetworkingManagerDelegate {
  
  func requestStarted() {
    if let count = schedule?.fetchedObjects?.count, count > 0 {
      activityIndicator.stopAnimating()
    } else {
      activityIndicator.startAnimating()
    }
  }
  
  func requestFailed() {
    activityIndicator.stopAnimating()
  }
  
  func requestSucceed() {
    activityIndicator.stopAnimating()
  }
}

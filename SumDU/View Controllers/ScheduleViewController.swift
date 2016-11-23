//
//  ScheduleViewController.swift
//  SumDU
//
//  Created by Yura Voevodin on 20.12.15.
//  Copyright © 2015 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit
import SwiftyJSON

class ScheduleViewController: UIViewController {
  
  // MARK: - Variables
  
  /// Data from SearchController
  fileprivate var listData: ListData?
  
  /// Object of Parser class
  var parser = Parser()
  
  /// Schedule records separated by sections
  fileprivate var recordsBySection: [Section] = [] {
    didSet {
      scheduleTableView.reloadData()
    }
  }
  
  /// URL for add schedule events to calendar
  fileprivate var calendarURL: URL?
  
  // MARK: - UI objects
  
  // Navigation bar
  fileprivate let backButton = BackButton()
  fileprivate let shareButton = ShareButton()
  fileprivate let refreshButton = RefreshButton()
  
  // Content
  fileprivate let titleLabel = UILabel()
  fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  fileprivate let informationLabel = UILabel()
  fileprivate let scheduleTableView = UITableView()
  
  // MARK: - Initialization
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.white
    
    let topMargin: CGFloat = 24.0
    let leadingMargin: CGFloat = 14.0
    let trailingMargin: CGFloat = 6.0
    
    // Parser
    parser.scheduleDelegate = self
    
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
      backButton.setImage(nil, for: UIControlState())
      backButton.setImage(nil, for: UIControlState.highlighted)
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
    scheduleTableView.register(ScheduleSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: ScheduleSectionHeaderView.reuseIdentifier)
    scheduleTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
    scheduleTableView.delegate = self
    scheduleTableView.dataSource = self
    scheduleTableView.separatorStyle = .none
    view.addSubview(scheduleTableView)
    constrain(scheduleTableView, titleLabel, view) {
      scheduleTableView, titleLabel, superview in
      
      scheduleTableView.top == titleLabel.bottom + 10.0
      scheduleTableView.leading == superview.leading
      scheduleTableView.trailing == superview.trailing
      scheduleTableView.bottom == superview.bottom
    }
    // Remove separators for empty cells
    scheduleTableView.tableFooterView = UIView()
    
    // Information
    informationLabel.text = NSLocalizedString("Sorry. There are no results for your request.", comment: "")
    informationLabel.font = Font.named(.helveticaNeueMedium, size: 20.0)
    informationLabel.textColor = Color.textNormal
    informationLabel.textAlignment = .center
    informationLabel.adjustsFontSizeToFitWidth = true
    informationLabel.minimumScaleFactor = 0.7
    view.addSubview(informationLabel)
    constrain(informationLabel, view) {
      informationLabel, superview in
      
      informationLabel.leading == superview.leading + 20.0
      informationLabel.trailing == superview.trailing - 20.0
      informationLabel.centerY == superview.centerY
    }
    
    // Indicator
    view.addSubview(activityIndicatorView)
    constrain(activityIndicatorView, view) { activityIndicatorView, superview in
      activityIndicatorView.center == superview.center
    }
  }
  
  fileprivate func updateTitleText() {
    if let data = listData {
      titleLabel.text = data.name
    } else {
      titleLabel.text = ""
    }
  }
  
  // MARK: - Actions
  
  /**
   Update data and UI in controller from storage
   */
  func updateFromStorage(withItem dataItem: ListData) {
    listData = dataItem
    
    // Load data
    recordsBySection = Section.loadData(UserDefaultsKey.scheduleKey(dataItem))
    
    // Update UI
    if recordsBySection.count == 0 {
      informationLabel.isHidden = false
      scheduleTableView.isHidden = true
    } else {
      informationLabel.isHidden = true
      scheduleTableView.isHidden = false
    }
    updateTitleText()
  }
  
  /**
   Update data and UI in controller from server
   */
  func updateFromServer(withItem item: ListData) {
    listData = item
    
    // Update UI
    informationLabel.isHidden = true
    scheduleTableView.isHidden = true
    updateTitleText()
    
    // Send request
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    activityIndicatorView.startAnimating()
    parser.sendScheduleRequest(listData)
  }
  
  func backButtonPressed() {
    if UIDevice.current.userInterfaceIdiom == .phone {
      let _ = navigationController?.popViewController(animated: true)
    }
  }
  
  /// Refresh schedule table
  func refreshButtonPressed() {
    parser.sendScheduleRequest(listData)
  }
  
  /// Share schedule
  func shareButtonPressed() {
    if recordsBySection.count > 0 {
      parser.generateCalendarURL(listData)
      if let url = calendarURL {
        UIApplication.shared.openURL(url)
      }
    }
  }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return ScheduleTableViewCell.cellHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ScheduleSectionHeaderView.reuseIdentifier) as! ScheduleSectionHeaderView
    // Set data
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM"
    headerView.dateLabel.text = dateFormatter.string(from: recordsBySection[section].date as Date)
    dateFormatter.dateFormat = "EEEE"
    headerView.dayLabel.text = dateFormatter.string(from: recordsBySection[section].date as Date)
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return ScheduleSectionHeaderView.viewHeight
  }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return recordsBySection.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recordsBySection[section].records.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath) as! ScheduleTableViewCell
    let scheduleRecord = recordsBySection[(indexPath as NSIndexPath).section].records[(indexPath as NSIndexPath).row]
    cell.update(withSchedule: scheduleRecord)
    return cell
  }
}

// MARK: - ParserScheduleDelegate

extension ScheduleViewController: ParserScheduleDelegate {
  
  func getSchedule(_ response: JSON) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    if let jsonArray = response.array , jsonArray.count > 0 {
      // All schedule records
      var allScheduleRecords: [Schedule] = []
      
      // All schedule records separated by sections
      var forRecordsBySection: [Section] = []
      
      // Set of the unique schedule dates
      var sectionsDate = [Date]()
      
      // Iterate JSON array
      for subJson in jsonArray {
        
        // Init schedule object
        if let scheduleRecord = Schedule(record: subJson) {
          
          // Fill dates array
          sectionsDate.append(scheduleRecord.pairDate)
          
          // Fill schedule array
          allScheduleRecords.append(scheduleRecord)
        }
      }
      // Order set of dates
      let orderedDates = Set(sectionsDate).sorted {
        $0.compare($1) == .orderedAscending
      }
      // Iterate all dates
      for singleDate in orderedDates {
        
        // For schedule records in single section
        var scheduleRecordsInSection: [Schedule] = []
        
        // Iterate all schedule records
        for singleScheduleRecord in allScheduleRecords {
          
          // If section date equals date of schedule record
          if singleDate == singleScheduleRecord.pairDate as Date {
            
            // Append schedule record to section array
            scheduleRecordsInSection.append(singleScheduleRecord)
          }
        }
        // Sort schedule records in single section by pair order name
        scheduleRecordsInSection.sort {
          $0.pairOrderName < $1.pairOrderName
        }
        // Append to array of sections
        forRecordsBySection.append(Section(date: singleDate, records: scheduleRecordsInSection))
      }
      // Update UI
      informationLabel.isHidden = true
      scheduleTableView.isHidden = false
      
      // Move data from temporary var to public
      recordsBySection = forRecordsBySection
      // Save data to persistent storage
      if let data = listData { Section.saveData(recordsBySection, forKey: UserDefaultsKey.scheduleKey(data)) }
    } else {
      // Empty data
      informationLabel.isHidden = false
      scheduleTableView.isHidden = true
    }
    // Tell refresh control it can stop showing up now
    activityIndicatorView.stopAnimating()
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
  func getCalendar(_ url: URL?) {
    calendarURL = url
  }
  
  func scheduleRequestError(_ parser: Parser, localizedError error: String?) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
    activityIndicatorView.stopAnimating()
    
    // Create alert
    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title in alerts"), style: .default, handler: nil))
    
    // Present alert
    present(alertController, animated: true, completion: nil)
  }
}

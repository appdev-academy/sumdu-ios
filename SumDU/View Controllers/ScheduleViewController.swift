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
    private var listData: ListData?
    
    /// Object of Parser class
    var parser = Parser()
    
    /// Schedule records separated by sections
    private var recordsBySection: [Section] = [] {
        didSet {
            scheduleTableView.reloadData()
        }
    }
    
    /// URL for add schedule events to calendar
    private var calendarURL: NSURL?
    
    // MARK: - UI objects
    
    // Navigation bar
    private let backButton = BackButton()
    private let shareButton = ShareButton()
    private let refreshButton = RefreshButton()
    
    // Content
    private let titleLabel = UILabel()
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private let informationLabel = UILabel()
    private let scheduleTableView = UITableView()
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let topMargin: CGFloat = 24.0
        let leadingMargin: CGFloat = 14.0
        let trailingMargin: CGFloat = 6.0
        
        // Parser
        parser.scheduleDelegate = self
        
        // Back
        backButton.addTarget(self, action: #selector(backButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
        constrain(backButton, view) {
            backButton, superview in
            
            backButton.top == superview.top + topMargin
            backButton.leading == superview.leading + leadingMargin
            backButton.height == BackButton.buttonSize.height
            backButton.width == BackButton.buttonSize.width
        }
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            backButton.setImage(nil, forState: UIControlState.Normal)
            backButton.setImage(nil, forState: UIControlState.Highlighted)
        }
        // Refresh
        refreshButton.addTarget(self, action: #selector(refreshButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(refreshButton)
        constrain(refreshButton, view) {
            refreshButton, superview in
            
            refreshButton.top == superview.top + topMargin
            refreshButton.trailing == superview.trailing - trailingMargin
            refreshButton.height == RefreshButton.buttonSize.height
            refreshButton.width == RefreshButton.buttonSize.width
        }
        // Share
        shareButton.addTarget(self, action: #selector(shareButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(shareButton)
        constrain(shareButton, refreshButton, view) {
            shareButton, refreshButton, superview in
            
            shareButton.top == superview.top + topMargin
            shareButton.trailing == refreshButton.leading - 2.0
            shareButton.height == ShareButton.buttonSize.height
            shareButton.width == ShareButton.buttonSize.width
        }
        // Title
        titleLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 26.0)
        titleLabel.textColor = Color.textBlack
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        constrain(titleLabel, backButton, view) {
            titleLabel, backButton, superview in
            
            titleLabel.top == backButton.bottom + 10.0
            titleLabel.leading == superview.leading + leadingMargin
            titleLabel.trailing == superview.trailing - trailingMargin
        }
        // Schedule table
        scheduleTableView.registerClass(ScheduleSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: ScheduleSectionHeaderView.reuseIdentifier)
        scheduleTableView.registerClass(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.separatorStyle = .None
        view.addSubview(scheduleTableView)
        constrain(scheduleTableView, titleLabel, view) {
            scheduleTableView, titleLabel, superview in
            
            scheduleTableView.top == titleLabel.bottom + 20.0
            scheduleTableView.leading == superview.leading
            scheduleTableView.trailing == superview.trailing
            scheduleTableView.bottom == superview.bottom
        }
        // Remove separators for empty cells
        scheduleTableView.tableFooterView = UIView()
        
        // Information
        informationLabel.text = NSLocalizedString("Sorry. There are no results for your request.", comment: "")
        informationLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 20.0)
        informationLabel.textColor = Color.textNormal
        informationLabel.textAlignment = .Center
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
    
    private func updateTitleText() {
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
            informationLabel.hidden = false
            scheduleTableView.hidden = true
        } else {
            informationLabel.hidden = true
            scheduleTableView.hidden = false
        }
        updateTitleText()
    }
    
    /**
        Update data and UI in controller from server
    */
    func updateFromServer(withItem item: ListData) {
        listData = item
        
        // Update UI
        informationLabel.hidden = true
        scheduleTableView.hidden = true
        updateTitleText()
        
        // Send request
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        activityIndicatorView.startAnimating()
        parser.sendScheduleRequest(listData)
    }
    
    func backButtonPressed() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            navigationController?.popViewControllerAnimated(true)
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
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate { }

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScheduleSectionHeaderView.viewHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(ScheduleSectionHeaderView.reuseIdentifier) as! ScheduleSectionHeaderView
        // Set data
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        headerView.dateLabel.text = dateFormatter.stringFromDate(recordsBySection[section].date)
        dateFormatter.dateFormat = "EEEE"
        headerView.dayLabel.text = dateFormatter.stringFromDate(recordsBySection[section].date)
        return headerView
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return recordsBySection.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsBySection[section].records.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ScheduleTableViewCell.cellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ScheduleTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
        let scheduleRecord = recordsBySection[indexPath.section].records[indexPath.row]
        cell.update(withSchedule: scheduleRecord)
        return cell
    }
}

// MARK: - ParserScheduleDelegate

extension ScheduleViewController: ParserScheduleDelegate {
    
    func getSchedule(response: JSON) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if let jsonArray = response.array where jsonArray.count > 0 {
            // All schedule records
            var allScheduleRecords: [Schedule] = []
            
            // All schedule records separated by sections
            var forRecordsBySection: [Section] = []
            
            // Set of the unique schedule dates
            var sectionsDate = [NSDate]()
            
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
            let orderedDates = Set(sectionsDate).sort {
                $0.compare($1) == .OrderedAscending
            }
            // Iterate all dates
            for singleDate in orderedDates {
                
                // For schedule records in single section
                var scheduleRecordsInSection: [Schedule] = []
                
                // Iterate all schedule records
                for singleScheduleRecord in allScheduleRecords {
                    
                    // If section date equals date of schedule record
                    if singleDate == singleScheduleRecord.pairDate {
                        
                        // Append schedule record to section array
                        scheduleRecordsInSection.append(singleScheduleRecord)
                    }
                }
                // Sort schedule records in single section by pair order name
                scheduleRecordsInSection.sortInPlace {
                    $0.pairOrderName < $1.pairOrderName
                }
                // Append to array of sections
                forRecordsBySection.append(Section(date: singleDate, records: scheduleRecordsInSection))
            }
            // Update UI
            informationLabel.hidden = true
            scheduleTableView.hidden = false
            
            // Move data from temporary var to public
            recordsBySection = forRecordsBySection
            // Save data to persistent storage
            if let data = listData { Section.saveData(recordsBySection, forKey: UserDefaultsKey.scheduleKey(data)) }
        } else {
            // Empty data
            informationLabel.hidden = false
            scheduleTableView.hidden = true
        }
        // Tell refresh control it can stop showing up now
        activityIndicatorView.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    /// Get calendar URL
    func getCalendar(url: NSURL?) {
        calendarURL = url
    }
}
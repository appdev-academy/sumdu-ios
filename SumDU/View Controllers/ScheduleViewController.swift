//
//  ScheduleViewController.swift
//  SumDU
//
//  Created by Yura on 20.12.15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import UIKit
import SwiftyJSON

class ScheduleViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scheduleNavigation: UINavigationItem!
    
    // MARK: - Constants
    
    private let kCellReuseIdentifier = "kCellReuseIdentifierSchedule"
    
    // MARK: - Variables
    
    /// Data from SearchController
    var listData: ListData?
    
    /// Object of Parser class
    var parser = Parser()
    
    /// Schedule records separetad by sections
    var recordsBySection: [Section] = [] {
        didSet {
            // Reload table data after fill an array
            tableView.reloadData()
        }
    }
    
    /// Control refresh
    var refreshControl = UIRefreshControl()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove separators for empty cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Delegate relations here
        parser.scheduleDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set title to navigation bar
        scheduleNavigation.title = listData?.name
        
        // Set up the refresh control
        self.refreshControl.attributedTitle = NSAttributedString(string: "Потягніть для оновлення")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(refreshControl)
        
        // Load schedule for selected row
        self.loadShedule()
        
    }
    
    /// Refresh shcedule table
    func refresh() {
        self.loadShedule()
    }
    
    /// Prepea and send schedule request in controller
    func loadShedule() {
        // send request with parameters to get records of schedule
        parser.sendScheduleRequest(listData)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Reload schedule, send new request
    @IBAction func refreshSchedule(sender: AnyObject) {
        self.loadShedule()
    }
    
    /// Share schedule
    @IBAction func share(sender: UIBarButtonItem) {
        let share = UIActivityViewController(activityItems: [], applicationActivities: nil)
        self.presentViewController(share, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate { }

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // Create a date formatter
        let dateFormatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "uk_UA_POSIX")
        dateFormatter.dateFormat = "dd MMMM, EEEE"
        dateFormatter.locale = locale
        
        // Generate section header
        let sectionHeader = dateFormatter.stringFromDate(recordsBySection[section].date)
        
        return sectionHeader
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return recordsBySection.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsBySection[section].records.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! ScheduleCell
        
        let scheduleRecord = recordsBySection[indexPath.section].records[indexPath.row]
        
        cell.pairName.text = scheduleRecord.pairName
        cell.pairTime.text = scheduleRecord.pairTime
        cell.pairType.text = scheduleRecord.pairType
        cell.auditoriumName.text = scheduleRecord.auditoriumName
        cell.teacherName.text = scheduleRecord.teacherName
        cell.groupName.text = scheduleRecord.groupName
        
        return cell
    }
}

// MARK: - ParserScheduleDelegate

extension ScheduleViewController: ParserScheduleDelegate {
    
    func getSchedule(response: JSON) {
        
        if let jsonArray = response.array where jsonArray.count > 0 {
            
            // All schedule records
            var allScheduleRecords: [Schedule] = []
            
            // All schedule records sepatated by sections
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
                forRecordsBySection.append(Section(title: singleDate, records: scheduleRecordsInSection))
            }
            
            // Move data from tempopary var to public
            recordsBySection = forRecordsBySection
        }
        
        // Tell refresh control it can stop showing up now
        if self.refreshControl.refreshing {
            self.refreshControl.endRefreshing()
        }
    }
}

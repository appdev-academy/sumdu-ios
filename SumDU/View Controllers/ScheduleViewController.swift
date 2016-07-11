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
    
    @IBOutlet weak var shareSchedule: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: - Constants
    
    private let kCellReuseIdentifier = "kCellReuseIdentifierSchedule"
    
    // MARK: - Variables
    
    /// Data from SearchController
    var listData: ListData? {
        didSet {
            self.saveListDataObject(self.listData, forKey: UserDefaultsKey.ScheduleListData.key)
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                if listData == self.listData {
                    self.scheduleNavigation.title = listData?.name
                    self.refreshButton.enabled = true
                    self.shareSchedule.enabled = true
                    self.loadSchedule()
                    if listData != nil {
                        self.recordsBySection = self.loadSectionDataObjects(UserDefaultsKey.scheduleKey(listData!))
                    }
                }
            }
        }
    }
    
    /// Object of Parser class
    private var parser = Parser()
    
    /// Schedule records separetad by sections
    private var recordsBySection: [Section] = [] {
        didSet {
            self.saveSectionData(self.recordsBySection, forKey: UserDefaultsKey.scheduleKey(listData!))
            tableView.reloadData()
        }
    }
    
    /// Control refresh
    private var refreshControl = UIRefreshControl()
    
    /// URL for add shedule ivents to calendar
    private var calendarURL: NSURL?
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove separators for empty cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Delegate relations here
        parser.scheduleDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let attributes = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        // Set up the refresh control
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to refresh", comment: ""))
        self.refreshControl.addTarget(self, action: #selector(ScheduleViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(refreshControl)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            // Set title to navigation bar
            scheduleNavigation.title = listData?.name
            
            // Load schedule for selected row
            self.loadSchedule()
            if let listData = self.loadListDataObject(UserDefaultsKey.ScheduleListData.key) {
                self.recordsBySection = self.loadSectionDataObjects(UserDefaultsKey.scheduleKey(listData))
            }
        }
    }
    
    /// Save schedule information to userDefaults
    private func saveSectionData(listDataCoder: [Section], forKey: String) {
        var sectionCoder: [SectionCoder] = []
        for sectionCoderRecord in listDataCoder {
            sectionCoder.append(sectionCoderRecord.sectionCoder)
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(sectionCoder)
        userDefaults.setObject(data, forKey: forKey)
        userDefaults.synchronize()
    }
    
    /// Load schedule information from userDefaults
    func loadSectionDataObjects(forKey: String) -> [Section] {
        var section: [Section] = []
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let listScheduleCoder = userDefaults.dataForKey(forKey) {
            
            if let listScheduleDataArray = NSKeyedUnarchiver.unarchiveObjectWithData(listScheduleCoder) as? [SectionCoder] {
                for scheduleDataStruct in listScheduleDataArray {
                    if let sectionData = scheduleDataStruct.section {
                        section.append(sectionData)
                    }
                }
            }
        }
        return section
    }
    
    /// Function which stores ListData entity
    func saveListDataObject(listDataObject: ListData?, forKey: String) {
        var listDataCoders: [ListDataCoder] = []
        if let lisData = listDataObject {
            listDataCoders.append(lisData.listDataCoder)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let data = NSKeyedArchiver.archivedDataWithRootObject(listDataCoders)
            userDefaults.setObject(data, forKey: forKey)
            userDefaults.synchronize()
        }
    }
    
    /// Function which loads ListData entity
    func loadListDataObject(forKey: String) -> ListData? {
        var listDataRecord: ListData?
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let listDataCoder = userDefaults.dataForKey(forKey) {
            
            if let listData = NSKeyedUnarchiver.unarchiveObjectWithData(listDataCoder) as? ListDataCoder {
                listDataRecord = listData.listData!
                return listDataRecord
            }
        }
        return listDataRecord
    }
    
    /// Refresh shcedule table
    func refresh() {
        self.parser.sendScheduleRequest(listData)
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    /// Prepare and send schedule request in controller
    private func loadSchedule() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let allKeys = userDefaults.dictionaryRepresentation().keys
        if let listData = self.listData where allKeys.contains(UserDefaultsKey.scheduleKey(listData)) {
            self.parser.sendScheduleRequest(listData)
        } else {
            self.parser.sendScheduleRequest(listData)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Reload schedule, send new request
    @IBAction func refreshSchedule(sender: AnyObject) {
        self.parser.sendScheduleRequest(listData)
    }
    
    /// Share schedule
    @IBAction func share(sender: UIBarButtonItem) {
        
        parser.generateCalendarURL(listData)
        
        if let url = calendarURL {
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate { }

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // Create a date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM, EEEE"
        
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
        
        // Set pair name and type
        var pairNameInCell = "-/-"
        
        if scheduleRecord.pairName.characters.count > 0 {
            pairNameInCell = scheduleRecord.pairName
        }
        
        if scheduleRecord.pairType.characters.count > 0 && scheduleRecord.pairName.characters.count > 0 {
            pairNameInCell += " (" + scheduleRecord.pairType + ")"
        }
        
        if scheduleRecord.pairType.characters.count > 0 && scheduleRecord.pairName.characters.count == 0 {
            pairNameInCell = scheduleRecord.pairType
        }
        
        cell.pairName.text = pairNameInCell
        
        // Set teacher name for pair
        var pairTeacterNameInCell = scheduleRecord.auditoriumName
        
        if scheduleRecord.teacherName.characters.count > 0 {
            pairTeacterNameInCell = scheduleRecord.teacherName
            
            if scheduleRecord.auditoriumName.characters.count > 0 {
                pairTeacterNameInCell += ", " + scheduleRecord.auditoriumName
            }
        }
        
        cell.teacherName.text = pairTeacterNameInCell
        
        // Set pair time in cell
        cell.pairTime.text = scheduleRecord.pairTime
        
        // Set pair groups
        var groupNameForCell = ""
        
        if scheduleRecord.groupName.characters.count > 0 {
            groupNameForCell = NSLocalizedString(" for ", comment: "") + scheduleRecord.groupName
        }
        cell.groupName.text = groupNameForCell
        
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
                forRecordsBySection.append(Section(date: singleDate, records: scheduleRecordsInSection))
            }
            
            // Move data from tempopary var to public
            recordsBySection = forRecordsBySection
        }
        
        // Tell refresh control it can stop showing up now
        if self.refreshControl.refreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    /// Get calendar URL
    func getCalendar(url: NSURL?) {
        calendarURL = url
    }
}

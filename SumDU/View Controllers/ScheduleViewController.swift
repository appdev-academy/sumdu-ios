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
    
    /// Schedule table sections
    private var allSections: [String] = [] {
        didSet {
            self.allSections.sortInPlace({
                $0.compare($1) == .OrderedAscending
            })
        }
    }
    
    /// Schedule records separetad by sections
    var recordsBySections = Array<Array<Schedule>>() {
        didSet {
            // Reload table data after fill an array
            tableView.reloadData()
        }
    }
    
    var refreshControl = UIRefreshControl()
    
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate { }

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allSections[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return allSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsBySections[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! ScheduleCell
        
        let scheduleRecord = recordsBySections[indexPath.section][indexPath.row]
        
        if scheduleRecord.pairName.characters.count > 0 {
            cell.pairName.text = scheduleRecord.pairName
        } else {
            // TODO: update cell constraint if label is empty (for all lables)
        }
        
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
            
            // TODO: check sections logic
            
            // TODO: order sections by date
            
            // Temporary array for all records
            var scheduleArray = Array<Schedule>()
            
            // Temporary array for records separated by sections
            var forRecordsBySections = Array<Array<Schedule>>()
            
            // All schedule dates
            var scheduleDates = [String]()
            
            // Iterate all elements in json array
            for subJson in jsonArray {
                
                // Init schedule object
                if let scheduleRecord = Schedule(record: subJson) {
                    
                    // Fill schedule array
                    scheduleArray.append(scheduleRecord)
                    
                    // Fill dates array
                    scheduleDates.append(scheduleRecord.pairDate)
                }
            }
            
            // Set of unique schedule dates
            let dateSet = Set(scheduleDates)
            
            // And array of unique schedule dates
            allSections = Array(dateSet)
            
            // Iterate thrue all available sections
            for oneSection in allSections {
                
                // Array of single section
                var singleSection: [Schedule] = []
                
                for element in scheduleArray {
                    
                    if oneSection == element.pairDate {
                        
                        // Append schedule record in section
                        singleSection.append(element)
                    }
                }
                
                // Combine all not empty sections together
                if singleSection.count > 0 {
                    
                    // Sorting recird in schedule section by pair
                    let sortedSection = singleSection.sort({
                        $0.pairOrderName.compare($1.pairOrderName) == .OrderedAscending
                    })
                    
                    // Final append to array
                    forRecordsBySections.append(sortedSection)
                }
            }
            // Move data from tempopary var to public
            recordsBySections = forRecordsBySections
        }
        
        // Tell refresh control it can stop showing up now
        if self.refreshControl.refreshing
        {
            self.refreshControl.endRefreshing()
        }
    }
}

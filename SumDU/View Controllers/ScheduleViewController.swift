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
    
    // MARK: - Constants
    
    private let kCellReuseIdentifier = "kCellReuseIdentifierSchedule"
    
    private let sections = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
    ]
    
     // MARK: - Variables
    
    /// Array of schedule records
    var allRecords: [Schedule] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    /// Object of Parser class
    var parser = Parser()
    
    /// Data from SearchController
    var listData: ListData?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Please, explain this line again
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        
        // Delegate relations here
        parser.scheduleDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get start date
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let startDate = dateFormatter.stringFromDate(currentDate)
        
        
        let additionalDays = 7
        let components = NSDateComponents()
        components.day = additionalDays
        
        // important: NSCalendarOptions(0)
        let futureDate = NSCalendar.currentCalendar()
            .dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))
        
        let endDate = dateFormatter.stringFromDate(futureDate!)
        
        
        // example of schedule request parametes
        let requestData : [String : String] =
        [
            ScheduleRequestParameter.BeginDate.rawValue: startDate,
            ScheduleRequestParameter.EndDate.rawValue: endDate,
            ScheduleRequestParameter.GroupId.rawValue: "100597",
            ScheduleRequestParameter.NameId.rawValue: "0",
            ScheduleRequestParameter.LectureRoomId.rawValue: "0",
            ScheduleRequestParameter.PublicDate.rawValue: "true",
            ScheduleRequestParameter.Param.rawValue: "0"
        ]
        
        // send request with parameters to get records of schedule
        parser.sendScheduleRequest(requestData)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRecords.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath)
        
        let text = allRecords[indexPath.row].dayOfWeek
            + " " + allRecords[indexPath.row].pairOrderName
        cell.textLabel?.text = text
        return cell
    }
}

// MARK: - ParserScheduleDelegate

extension ScheduleViewController: ParserScheduleDelegate {
    
    func getSchedule(response: JSON) {
        
        if let jsonArray = response.array where jsonArray.count > 0 {
            
            for subJson in jsonArray {
                
                // append schedule object to array of all records
                if let scheduleRecord = Schedule(record: subJson) {
                    allRecords.append(scheduleRecord)
                }
            }
        }
    }
}

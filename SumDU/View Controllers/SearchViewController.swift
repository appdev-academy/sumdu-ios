//
//  SearchViewController.swift
//  SumDU
//
//  Created by Maksym Skliarov on 12/10/15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchViewController: UIViewController {
    
    enum SelectedSegment {
        case Teachers
        case Groups
        case Auditoriums
        case Favorites
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Constants
    
    private let kCellReuseIdentifier = "kCellReuseIdentifier"
    
    // MARK: - Variables
    
    /// Parser instance
    var parser = Parser()
    /// Array of all Auditoriums
    var allAuditoriums: [ListData] = [] {
        didSet {
            ListData.saveListDataObjects(allAuditoriums, forKey: keyAuditoriums)
            self.tableView.reloadData()
        }
    }
    /// Array of all Groups
    var allGroups: [ListData] = [] {
        didSet {
            ListData.saveListDataObjects(allGroups, forKey: keyGroups)
            self.tableView.reloadData()
        }
    }
    /// Array of all Teachers
    var allTeachers: [ListData] = [] {
        didSet {
            ListData.saveListDataObjects(allTeachers, forKey: keyTeachers)
            self.tableView.reloadData()
        }
    }
    /// Currently selected segment
    var selectedSegment: SelectedSegment = SelectedSegment.Teachers {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    /// Remember data of selected cell
    var selectedCell: ListData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        
        // Set DataListDelegate for Parser
        parser.dataListDelegate = self
        
        // Auditories request example
        parser.sendDataRequest(.Auditorium)
        
        // Teachers request example
        parser.sendDataRequest(.Teacher)
        
        // Groups request example
        parser.sendDataRequest(.Group)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Setting up destination view controller data source here
        if segue.identifier == "ShowSchedule" {
            if let scheduleViewController = segue.destinationViewController as? ScheduleViewController {
                scheduleViewController.listData = selectedCell
            }
        }
        
    }
    
    @IBAction private func selectionDidChange(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                self.selectedSegment = .Teachers
            case 1:
                self.selectedSegment = .Groups
            case 2:
                self.selectedSegment = .Auditoriums
            case 3:
                self.selectedSegment = .Favorites
            default:
                print("Unknown selected segment in SearchViewController")
        }
    }
}

extension SearchViewController: ParserDataListDelegate {
    /// Realization of ParserDelegate protocol function for getting related data (teachers, groups and auditorium data)
    func getRelatedData(response: JSON, requestType: ListDataType) {
        
        var recordsToUpdate: [ListData] = []
        
        // Make sure JSON is array and not empty
        if let jsonArray = response.array where jsonArray.count > 0 {
            
            for subJson in jsonArray {
                if let record = ListData(json: subJson, type: requestType) {
                    recordsToUpdate.append(record)
                }
            }
            
            // Assign array of corresponding objects
            switch requestType {
                case .Auditorium:
                    allAuditoriums = recordsToUpdate
                case .Group:
                    allGroups = recordsToUpdate
                case .Teacher:
                    allTeachers = recordsToUpdate
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        var dataList: [ListData] = allTeachers
        switch selectedSegment {
        case .Teachers:
            dataList = allTeachers
        case .Groups:
            dataList = allGroups
        case .Auditoriums:
            dataList = allAuditoriums
        case .Favorites:
            dataList = []
        }
        
        // Remember selected sell
        selectedCell = dataList[indexPath.item]
        
        self.performSegueWithIdentifier("ShowSchedule", sender: nil)
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedSegment {
            case .Teachers:
                return allTeachers.count
            case .Groups:
                return allGroups.count
            case .Auditoriums:
                return allAuditoriums.count
            case .Favorites:
                return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath)
        var dataList: [ListData] = allTeachers
        switch selectedSegment {
            case .Teachers:
                dataList = allTeachers
            case .Groups:
                dataList = allGroups
            case .Auditoriums:
                dataList = allAuditoriums
            case .Favorites:
                dataList = []
        }
        
        cell.textLabel?.text = dataList[indexPath.row].name
        return cell
    }
}
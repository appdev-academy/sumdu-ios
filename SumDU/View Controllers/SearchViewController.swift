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
    
    var searchActive : Bool = false
    var filtered:[ListData] = []
    
    /// Parser instance
    var parser = Parser()
    /// Array of all Auditoriums
    var allAuditoriums: [ListData] = [] {
        didSet {
            saveListDataObjects(allAuditoriums, forKey: keyAuditoriums)
            self.tableView.reloadData()
        }
    }
    /// Array of all Groups
    var allGroups: [ListData] = [] {
        didSet {
            saveListDataObjects(allGroups, forKey: keyGroups)
            self.tableView.reloadData()
        }
    }
    /// Array of all Teachers
    var allTeachers: [ListData] = [] {
        didSet {
            saveListDataObjects(allTeachers, forKey: keyTeachers)
            self.tableView.reloadData()
        }
    }
    /// Currently selected segment
    var selectedSegment: SelectedSegment = SelectedSegment.Teachers {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        
        // Load Auditoriums from UserDefaults
        self.allAuditoriums = loadListDataObjects(keyAuditoriums)

        // Load Groups from UserDefaults
        self.allGroups = loadListDataObjects(keyGroups)

        // Load Teachers from UserDefaults
        self.allTeachers = loadListDataObjects(keyTeachers)
        
        // Set DataListDelegate for Parser
        parser.dataListDelegate = self
        
        // Auditories request example
        parser.sendDataRequest(.Auditorium)
        
        // Teachers request example
        parser.sendDataRequest(.Teacher)
        
        // Groups request example
        parser.sendDataRequest(.Group)
        
        //set delegate for searchBar
        searchBar.delegate = self
    }
    
    /// Function which stores ListData entities using NSUserDefaults class
    func saveListDataObjects(listDataObject: [ListData], forKey: String) {
        var listDataCoders: [ListDataCoder] = []
        for listDataRecord in listDataObject {
            listDataCoders.append(listDataRecord.listDataCoder)
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(listDataCoders)
        userDefaults.setObject(data, forKey: forKey)
        userDefaults.synchronize()
    }
    
    /// Function which loads ListData entities from NSUserDefaults class
    func loadListDataObjects(forKey: String) -> [ListData] {
        var listData: [ListData] = []
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let listDataCoder = userDefaults.dataForKey(forKey) {
        
            if let listDataArray = NSKeyedUnarchiver.unarchiveObjectWithData(listDataCoder) as? [ListDataCoder] {
                for array in listDataArray {
                    listData.append(ListData(id: array.listData!.id, name: array.listData!.name, type: array.listData!.type))
                }
                return listData
            }
        }
        return listData
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Set up destination view controller data source here
//        if let scheduleViewController = segue.destinationViewController as? ScheduleViewController {
//            
//        }
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
                print("Unkown selected segment in SearchViewController")
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
                if (searchActive) {
                    return filtered.count
                } else {
                    return allTeachers.count
                }
            case .Groups:
                if (searchActive) {
                    return filtered.count
                } else {
                return allGroups.count
                }
            case .Auditoriums:
                if (searchActive) {
                    return filtered.count
                } else {
                return allAuditoriums.count
                }
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
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row].name
        } else {
            cell.textLabel?.text = dataList[indexPath.row].name
        }
        
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.text = ""
        searchActive = false;
        searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        var listData: [ListData] = []
        switch selectedSegment {
            case .Teachers:
                listData = allTeachers
                filtered = listData.filter { return $0.name.lowercaseString.containsString(searchText.lowercaseString)}
            case .Groups:
                listData = allGroups
                filtered = listData.filter { return $0.name.lowercaseString.containsString(searchText.lowercaseString)}
            case .Auditoriums:
                listData = allAuditoriums
                filtered = listData.filter { return $0.name.lowercaseString.containsString(searchText.lowercaseString)}
            default: break
        }
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableView.reloadData()
    }
}

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
    var dataSource: [ListData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    /// Currently selected segment
    var selectedSegment: SelectedSegment = SelectedSegment.Teachers {
        didSet {
            self.filterDataSourceWithQuery(self.searchBar.text)
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        
        isAppLaunchedBefore()
        
        self.filterDataSourceWithQuery(nil)
        
        // Set DataListDelegate for Parser
        parser.dataListDelegate = self
        
        //set delegate for searchBar
        self.searchBar.delegate = self

    }
    
    /// Load data from site by specific period
    func scheduleLoadingData(startDate: NSDate) {
        if var endDate = NSUserDefaults.standardUserDefaults().valueForKey("endDate") as? NSDate {

            if endDate.compare(startDate) == NSComparisonResult.OrderedAscending {
                self.parser.sendDataRequest(.Auditorium)
                self.parser.sendDataRequest(.Teacher)
                self.parser.sendDataRequest(.Group)
            
                endDate = startDate.dateByAddingTimeInterval(days)
                NSUserDefaults.standardUserDefaults().setObject(endDate, forKey: "endDate")
            }
        }
    }
    
    /// Check if app is lauched before
    func isAppLaunchedBefore() -> Bool {
        if(NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce")) {
            
            let startDate = NSDate()
            scheduleLoadingData(startDate)
            
            // Load Auditoriums from UserDefaults
            self.allAuditoriums = loadListDataObjects(keyAuditoriums)
            // Load Groups from UserDefaults
            self.allGroups = loadListDataObjects(keyGroups)
            // Load Teachers from UserDefaults
            self.allTeachers = loadListDataObjects(keyTeachers)
            
            return true
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            
            let startDate = NSDate()
            let endDate = startDate.dateByAddingTimeInterval(20)
            NSUserDefaults.standardUserDefaults().setObject(endDate, forKey: "endDate")
            
            return false
        }
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
    
    /// Filter data source with search query
    private func filterDataSourceWithQuery(query: String?) {
        var listDataArray: [ListData] = []
        switch selectedSegment {
            case .Teachers:
                listDataArray = allTeachers
            case .Groups:
                listDataArray = allGroups
            case .Auditoriums:
                listDataArray = allAuditoriums
            case .Favorites:
                break
        }
        if let query = query where query.characters.count > 0 {
            dataSource = listDataArray.filter { return $0.name.lowercaseString.containsString(query.lowercaseString) }
        } else {
            dataSource = listDataArray
        }
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
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath)
        let listDataRecord = dataSource[indexPath.row]
        cell.textLabel?.text = listDataRecord.name
        
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        self.filterDataSourceWithQuery(nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.resignFirstResponder()
        enableCancelButton(searchBar)
    }
    
    func enableCancelButton(searchBar: UISearchBar) {
        let btnCancel: UIButton = searchBar.valueForKey("_cancelButton") as! UIButton
        btnCancel.enabled = true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterDataSourceWithQuery(searchText)
    }
}

extension SearchViewController: UIScrollViewDelegate {
    
    override func viewWillAppear(animated: Bool) {
        self.startKeyboardObserver()
        let startDate = NSDate()
        
        scheduleLoadingData(startDate)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.stopKeyboardObserver()
    }
    
    private func startKeyboardObserver(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func stopKeyboardObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height,  0.0);
                
                self.tableView.contentInset = contentInset
                self.tableView.scrollIndicatorInsets = contentInset
                
                self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, 0 + keyboardSize.height)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
}

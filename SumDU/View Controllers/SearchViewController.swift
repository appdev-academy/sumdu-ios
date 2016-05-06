//
//  SearchViewController.swift
//  SumDU
//
//  Created by Maksym Skliarov on 12/10/15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Cartography

class SearchViewController: UIViewController {
    
    enum SelectedSegment {
        case Teachers
        case Groups
        case Auditoriums
        case Favorites
        
        var name: String {
            
            switch self {
            case .Teachers:
                return NSLocalizedString("Teachers", comment: "")
                
            case .Groups:
                return NSLocalizedString("Groups", comment: "")
                
            case .Auditoriums:
                return NSLocalizedString("Auditoriums", comment: "")
                
            default: return ""
            }
        }
    }
    
    // MARK: - Outlets
    
//    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl!
//    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var refreshButton: UIBarButtonItem!
    
    // MARK: - UI objects
    private var collectionViewMenu: UICollectionView!
    private var bottomCollectionView: UICollectionView!
    
    //private let searchBar = SearchBar(frame: CGRectZero)
    private let searchBarContainer = SearchBarContainer(frame: CGRectZero)
//    private let containerForSegmentedControl = UIView(frame: CGRectZero)
//    private let highlightedSegmentedControlLine = UIView(frame: CGRectZero)
//    private let lineUderCollectionView = UIView(frame: CGRectZero)
//    private let collectionViewForTableViewCell = CollectionViewForTableViewCell(frame: CGRectZero)
    
    // MARK: - Constants
    
    private let kCellReuseIdentifier = "kCellReuseIdentifier"
    private let screenSize = UIScreen.mainScreen().bounds.size
    
    // MARK: - Variables
    
    var delegate: SearchViewControllerDelegate?
    /// Parser instance
    var parser = Parser()
    /// Array of all Auditoriums
    var allAuditoriums: [ListData] = [] {
        didSet {
            self.reloadListData(self.allAuditoriums, forKey: UserDefaultsKey.Auditoriums.key)
        }
    }
    /// Array of all Groups
    var allGroups: [ListData] = [] {
        didSet {
            self.reloadListData(self.allGroups, forKey: UserDefaultsKey.Groups.key)
        }
    }
    /// Array of all Teachers
    var allTeachers: [ListData] = [] {
        didSet {
            self.reloadListData(self.allTeachers, forKey: UserDefaultsKey.Teachers.key)
        }
    }
    var dataSource: [ListData] = [] {
        didSet {
//            self.tableView.reloadData()
        }
    }
    
    var history: [ListData] = [] {
        didSet {
            self.history = removeHistoryRecord(uniq(self.history))
            self.saveListDataObjects(self.history, forKey: UserDefaultsKey.History.key)
//            self.tableView.reloadData()
        }
    }
    
    /// Currently selected segment
    var selectedSegment: SelectedSegment = SelectedSegment.Favorites {
        didSet {
            self.filterDataSourceWithQuery(self.searchBarContainer.searchBar.getTextField?.text)
//            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            
            switch self.selectedSegment {
                
            case .Favorites: break
//                self.setDynamicConstraints(0.0, width: CollectionViewCellConstrains.imageWidth.rawValue)
                
            case .Teachers: break
//                self.setDynamicConstraints(self.calculateIndentBetweenObjectsIntoCollectionVIewCell() + CollectionViewCellConstrains.imageWidth.rawValue + 1.0, width: self.calculateLabelWidth(SelectedSegment.Teachers.name))
                
            case .Groups: break
//                self.setDynamicConstraints(self.calculateIndentBetweenObjectsIntoCollectionVIewCell()*2 + self.calculateLabelWidth(SelectedSegment.Teachers.name) + CollectionViewCellConstrains.imageWidth.rawValue + 1.0, width: self.calculateLabelWidth(SelectedSegment.Groups.name))
                
            case .Auditoriums: break
//                self.setDynamicConstraints(self.calculateIndentBetweenObjectsIntoCollectionVIewCell()*3 + self.calculateLabelWidth(SelectedSegment.Teachers.name) + self.calculateLabelWidth(SelectedSegment.Groups.name) + CollectionViewCellConstrains.imageWidth.rawValue + 1.0, width: self.calculateLabelWidth(SelectedSegment.Auditoriums.name))
                
            }
        }
    }
    
    /// Remember data of selected cell
    var selectedListDataObject: ListData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        
        // Load and filter initial data
        self.allTeachers = self.loadListDataObjects(UserDefaultsKey.Teachers.key)
        self.allGroups = self.loadListDataObjects(UserDefaultsKey.Groups.key)
        self.allAuditoriums = self.loadListDataObjects(UserDefaultsKey.Auditoriums.key)
        self.history = self.loadListDataObjects(UserDefaultsKey.History.key)
        
        self.filterDataSourceWithQuery(nil)
        
        self.registerForNotifications()
        
        // Set DataListDelegate for Parser
        self.parser.dataListDelegate = self
        
        // Set delegate for searchBar
        self.searchBarContainer.searchBar.getTextField?.delegate = self
        
        self.view.addSubview(self.searchBarContainer)
        
        self.setConstrain()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkUpdatedAtDateAndLoadData()
    }
    
    deinit {
        self.deregisterFromNotifications()
    }
    
    private func setConstrain() {
        
//        guard let collectionViewMenu = self.collectionViewMenu else {
//            return
//        }
        
        let views = [ self.searchBarContainer,
//                      self.containerForSegmentedControl,
//                      collectionViewMenu,
//                      self.highlightedSegmentedControlLine,
//                      self.lineUderCollectionView,
                      ]
        
        constrain(views) {
            views in
            
            let searchBarContainer = views[0]
//            let containerForSegmentedControl = views[1]
//            let collectionViewMenu = views[2]
//            let highlightedSegmentedControlLine = views[3]
//            let lineUderCollectionView = views[4]
            
            searchBarContainer.top == searchBarContainer.superview!.top + 30
            searchBarContainer.leading == searchBarContainer.superview!.leading + 14
            searchBarContainer.trailing == searchBarContainer.superview!.trailing - 14
            searchBarContainer.height == 44.0
            
//            containerForSegmentedControl.top == searchBarContainer.bottom + 1
//            containerForSegmentedControl.leading == containerForSegmentedControl.superview!.leading
//            containerForSegmentedControl.trailing == containerForSegmentedControl.superview!.trailing
//            containerForSegmentedControl.height == CollectionViewConstrains.CollectionViewCellHeight.rawValue + 2.0
//            
//            collectionViewMenu.top == containerForSegmentedControl.top + 1
//            collectionViewMenu.leading == containerForSegmentedControl.leading
//            collectionViewMenu.trailing == containerForSegmentedControl.trailing
//            collectionViewMenu.height == CollectionViewConstrains.CollectionViewCellHeight.rawValue
//            
//            lineUderCollectionView.leading == containerForSegmentedControl.leading
//            lineUderCollectionView.trailing == containerForSegmentedControl.trailing
//            lineUderCollectionView.top == containerForSegmentedControl.bottom
//            lineUderCollectionView.height == 1.0
//            
//            highlightedSegmentedControlLine.height == 2.0
//            highlightedSegmentedControlLine.bottom == lineUderCollectionView.bottom
            
        }
    }
    
    /// Refresh [ListData] objects
    @IBAction func refreshListDataObjects(sender: AnyObject) {
        self.parser.sendDataRequest(.Auditorium, updateButtonPressed: true)
        self.parser.sendDataRequest(.Teacher, updateButtonPressed: true)
        self.parser.sendDataRequest(.Group, updateButtonPressed: true)
    }
    
    /// Check if lists of Teachers, Groups and Auditoriums was updated more than 3 days ago
    func checkUpdatedAtDateAndLoadData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastUpdatedAtDate = defaults.objectForKey(UserDefaultsKey.LastUpdatedAtDate.key) as? NSDate
        if (lastUpdatedAtDate == nil) || (lastUpdatedAtDate != nil && lastUpdatedAtDate!.compare(NSDate().dateBySubtractingDays(3)) == .OrderedAscending) {
            self.parser.sendDataRequest(.Auditorium, updateButtonPressed: false)
            self.parser.sendDataRequest(.Teacher, updateButtonPressed: false)
            self.parser.sendDataRequest(.Group, updateButtonPressed: false)
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
        var listDataRecords: [ListData] = []
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let listDataCoder = userDefaults.dataForKey(forKey) {
            
            if let listDataArray = NSKeyedUnarchiver.unarchiveObjectWithData(listDataCoder) as? [ListDataCoder] {
                for listDataStruct in listDataArray {
                    if let listData = listDataStruct.listData {
                        listDataRecords.append(listData)
                    }
                }
                return listDataRecords
            }
        }
        return listDataRecords
    }
    
    /// Save corresponding array of ListData and update UI
    private func reloadListData(listData: [ListData], forKey key: String) {
        self.saveListDataObjects(listData, forKey: key)
        self.filterDataSourceWithQuery(self.searchBarContainer.searchBar.getTextField?.text)
//        self.tableView.reloadData()
    }
    
    /// Select only uniq data from History
    private func uniq <T: Equatable>(lst: [T]) -> [T] {
        var seen: [T] = []
        return lst.filter { x in
            let unseen = seen.indexOf(x) == nil
            if (unseen) {
                seen.append(x)
            }
            return unseen
        }
    }
    
    /// Remove the oldest saved data from History
    private func removeHistoryRecord(var array: [ListData]) -> [ListData] {
        while array.count > 50 {
            array.removeFirst()
        }
        return array
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
                listDataArray = history
        }
        if let query = query where query.characters.count > 0 {
            dataSource = listDataArray.filter { return $0.name.lowercaseString.containsString(query.lowercaseString) }
        } else {
            dataSource = listDataArray
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Setting up destination view controller data source here
        if let scheduleViewController = segue.destinationViewController as? ScheduleViewController where segue.identifier == "ShowSchedule" {
            scheduleViewController.listData = selectedListDataObject
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
    
    // MARK: - Notifications
    
    private func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func deregisterFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height,  0.0);
                
//                self.tableView.contentInset = contentInset
//                self.tableView.scrollIndicatorInsets = contentInset
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
//        self.tableView.contentInset = UIEdgeInsetsZero;
//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
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
                    self.allAuditoriums = recordsToUpdate.sort {$0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending}
                case .Group:
                    self.allGroups = recordsToUpdate.sort {$0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending}
                case .Teacher:
                    self.allTeachers = recordsToUpdate.sort {$0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending}
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Remember selected sell
        self.selectedListDataObject = dataSource[indexPath.row]
        self.history.append(selectedListDataObject!)
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.performSegueWithIdentifier("ShowSchedule", sender: nil)
        }
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.delegate?.setListDataObject(self.selectedListDataObject!)
        }
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
//        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if searchBar.text != "" {
            searchBar.showsCancelButton = true
            searchBar.resignFirstResponder()
        } else {
            searchBar.text = ""
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
//            self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.None
            self.filterDataSourceWithQuery(nil)
        }
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
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterDataSourceWithQuery(searchText)
    }
}

extension SearchViewController: UITextFieldDelegate {
    
}

protocol SearchViewControllerDelegate {
    func setListDataObject(listData: ListData)
}
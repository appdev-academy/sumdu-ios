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
    
    enum SelectedSegment: Int {
        case Favorites
        case Teachers
        case Groups
        case Auditoriums
        
        var name: String {
            
            switch self {
            case .Teachers:
                return NSLocalizedString("Teacher", comment: "")
                
            case .Groups:
                return NSLocalizedString("Group", comment: "")
                
            case .Auditoriums:
                return NSLocalizedString("Auditorium", comment: "")
                
            default: return ""
            }
        }
    }
    
    // MARK: - Outlets
    
    // MARK: - UI objects
    private var collectionViewMenu: UICollectionView!
    private var bottomCollectionView: UICollectionView!
    
    private let searchBarView = SearchBarView()
    private let containerForSegmentedControl = UIView(frame: CGRectZero)
    private let highlightedSegmentedControlLine = UIView(frame: CGRectZero)
    private let lineUderCollectionView = UIView(frame: CGRectZero)
    private let collectionViewForTableViewCell = CollectionViewForTableViewCell(frame: CGRectZero)
    
    private var tableView = UITableView()
    
    // MARK: - Constants
    
    private let screenSize = UIScreen.mainScreen().bounds.size
    
    // MARK: - Variables
    
    private var searchMode = false
    private var searchText: String?
    private var group = ConstraintGroup()
    
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
            self.tableView.reloadData()
        }
    }
    
    var history: [ListData] = [] {
        didSet {
            self.history = removeHistoryRecord(uniq(self.history))
            self.saveListDataObjects(self.history, forKey: UserDefaultsKey.History.key)
            self.tableView.reloadData()
        }
    }
    
    /// Currently selected segment
    var selectedSegment: SelectedSegment = .Favorites {
        didSet {
            self.filterDataSourceWithQuery(searchText)
            self.tableView.reloadData()
            switch self.selectedSegment {
                
            case .Favorites:
                self.setDynamicConstraints(0.0, width: CollectionViewCellConstrains.imageWidth.rawValue)
                
            case .Teachers:
                self.setDynamicConstraints(self.calculateIndentBetweenObjectsIntoCollectionVIewCell() + CollectionViewCellConstrains.imageWidth.rawValue + 1.0, width: self.calculateLabelWidth(SelectedSegment.Teachers.name))
                
            case .Groups:
                self.setDynamicConstraints(self.calculateIndentBetweenObjectsIntoCollectionVIewCell()*2 + self.calculateLabelWidth(SelectedSegment.Teachers.name) + CollectionViewCellConstrains.imageWidth.rawValue + 1.0, width: self.calculateLabelWidth(SelectedSegment.Groups.name))
                
            case .Auditoriums:
                self.setDynamicConstraints(self.calculateIndentBetweenObjectsIntoCollectionVIewCell()*3 + self.calculateLabelWidth(SelectedSegment.Teachers.name) + self.calculateLabelWidth(SelectedSegment.Groups.name) + CollectionViewCellConstrains.imageWidth.rawValue + 1.0, width: self.calculateLabelWidth(SelectedSegment.Auditoriums.name))
                
            }
        }
    }
    
    /// Remember data of selected cell
    var selectedListDataObject: ListData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        self.collectionViewMenu = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.collectionViewMenu.registerClass(CollectionViewMenuCell.self, forCellWithReuseIdentifier: "collectionMenuCell")
        self.collectionViewMenu.delegate = self
        self.collectionViewMenu.dataSource = self
        self.collectionViewMenu.showsVerticalScrollIndicator = false
        self.collectionViewMenu.showsHorizontalScrollIndicator = false
        self.collectionViewMenu.pagingEnabled = true
        self.collectionViewMenu.backgroundColor = UIColor.whiteColor()
        
        self.containerForSegmentedControl.addSubview(self.collectionViewMenu)
        
        self.highlightedSegmentedControlLine.backgroundColor = colorForSelectedObjects
        self.highlightedSegmentedControlLine.layer.zPosition = 2.0
        self.containerForSegmentedControl.addSubview(self.highlightedSegmentedControlLine)
        
        self.lineUderCollectionView.backgroundColor = lineColor
        self.lineUderCollectionView.layer.zPosition = 1.0
        self.containerForSegmentedControl.addSubview(self.lineUderCollectionView)
        
        // Load and filter initial data
        self.allTeachers = self.loadListDataObjects(UserDefaultsKey.Teachers.key)
        self.allGroups = self.loadListDataObjects(UserDefaultsKey.Groups.key)
        self.allAuditoriums = self.loadListDataObjects(UserDefaultsKey.Auditoriums.key)
        self.history = self.loadListDataObjects(UserDefaultsKey.History.key)
        
        self.filterDataSourceWithQuery(nil)
        
        self.registerForNotifications()
        
        // Set DataListDelegate for Parser
        self.parser.dataListDelegate = self
        
        self.tableView = self.collectionViewForTableViewCell.tableView
        self.tableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        searchBarView.delegate = self
        view.addSubview(searchBarView)
        view.addSubview(containerForSegmentedControl)
        
        self.selectedSegment = .Favorites
        
        self.setupBottomCollectionView()
        self.setupConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkUpdatedAtDateAndLoadData()
    }
    
    deinit {
        self.deregisterFromNotifications()
    }
    
    private func setupBottomCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        self.bottomCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.bottomCollectionView.backgroundColor = UIColor.whiteColor()
        self.bottomCollectionView.registerClass(CollectionViewForTableViewCell.self, forCellWithReuseIdentifier: "bottomCollectionViewCell")
        self.bottomCollectionView.showsVerticalScrollIndicator = false
        self.bottomCollectionView.showsHorizontalScrollIndicator = false
        self.bottomCollectionView.delegate = self
        self.bottomCollectionView.dataSource = self
        self.bottomCollectionView.bounces = false
        
        self.view.addSubview(self.bottomCollectionView)
        
        guard let bottomCollectionView = self.bottomCollectionView else {
            return
        }
        
        constrain(self.containerForSegmentedControl, bottomCollectionView) {
            containerForSegmentedControl, bottomCollectionView in
            
            bottomCollectionView.leading == bottomCollectionView.superview!.leading
            bottomCollectionView.trailing == bottomCollectionView.superview!.trailing
            bottomCollectionView.top == containerForSegmentedControl.bottom + 1
            bottomCollectionView.bottom == bottomCollectionView.superview!.bottom
            
        }
        
    }
    
    // Calculate lenght of textLabel
    private func calculateLabelWidth(label: String) -> CGFloat {
        return label.boundingRectWithSize(CGSize(width: DBL_MAX, height: DBL_MAX), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: titleTextFont], context: nil).size.width
    }
    
    // Calculate indents in CollectionViewCell
    private func calculateIndentBetweenObjectsIntoCollectionVIewCell() -> CGFloat {
        
        let screenWidth = min(self.screenSize.width, self.screenSize.height)
        
        let indent = (screenWidth - CollectionViewCellConstrains.imageWidth.rawValue - self.calculateLabelWidth(SelectedSegment.Teachers.name) - self.calculateLabelWidth(SelectedSegment.Groups.name) - self.calculateLabelWidth(SelectedSegment.Auditoriums.name))/4.00
        
        return indent
    }
    
    private func setDynamicConstraints(leading: CGFloat, width: CGFloat) {
        
        constrain(self.highlightedSegmentedControlLine, replace: self.group) {
            line in
            
            line.leading == line.superview!.leading + self.calculateIndentBetweenObjectsIntoCollectionVIewCell()/2.0 + leading
            line.width == width
            
        }
        
    }
    
    private func setupConstraints() {
        
        guard let collectionViewMenu = self.collectionViewMenu else {
            return
        }
        
        let views = [ self.searchBarView,
                      self.containerForSegmentedControl,
                      collectionViewMenu,
                      self.highlightedSegmentedControlLine,
                      self.lineUderCollectionView,
                      ]
        
        constrain(views) {
            views in
            
            let searchBarContainer = views[0]
            let containerForSegmentedControl = views[1]
            let collectionViewMenu = views[2]
            let highlightedSegmentedControlLine = views[3]
            let lineUderCollectionView = views[4]
            
            searchBarContainer.top == searchBarContainer.superview!.top + 30
            searchBarContainer.leading == searchBarContainer.superview!.leading + 14
            searchBarContainer.trailing == searchBarContainer.superview!.trailing - 14
            searchBarContainer.height == 44.0
            
            containerForSegmentedControl.top == searchBarContainer.bottom + 1
            containerForSegmentedControl.leading == containerForSegmentedControl.superview!.leading
            containerForSegmentedControl.trailing == containerForSegmentedControl.superview!.trailing
            containerForSegmentedControl.height == CollectionViewConstrains.CollectionViewCellHeight.rawValue + 2.0

            collectionViewMenu.top == containerForSegmentedControl.top + 1
            collectionViewMenu.leading == containerForSegmentedControl.leading
            collectionViewMenu.trailing == containerForSegmentedControl.trailing
            collectionViewMenu.height == CollectionViewConstrains.CollectionViewCellHeight.rawValue

            lineUderCollectionView.leading == containerForSegmentedControl.leading
            lineUderCollectionView.trailing == containerForSegmentedControl.trailing
            lineUderCollectionView.top == containerForSegmentedControl.bottom
            lineUderCollectionView.height == 1.0
            
            highlightedSegmentedControlLine.height == 2.0
            highlightedSegmentedControlLine.bottom == lineUderCollectionView.bottom
            
        }
    }
    
    /// Refresh [ListData] objects
    private func refreshListDataObjects() {
        parser.sendDataRequest(.Auditorium, updateButtonPressed: true)
        parser.sendDataRequest(.Teacher, updateButtonPressed: true)
        parser.sendDataRequest(.Group, updateButtonPressed: true)
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
        saveListDataObjects(listData, forKey: key)
        filterDataSourceWithQuery(searchText)
        tableView.reloadData()
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
    private func removeHistoryRecord(array: [ListData]) -> [ListData] {
        var localArray = array
        while localArray.count > 50 {
            localArray.removeFirst()
        }
        return localArray
    }
    
    /// Filter data source with search query
    private func filterDataSourceWithQuery(query: String?) {
        var listDataArray: [ListData] = []
        switch selectedSegment {
            case .Teachers:
                listDataArray = self.allTeachers
            case .Groups:
                listDataArray = self.allGroups
            case .Auditoriums:
                listDataArray = self.allAuditoriums
            case .Favorites:
                listDataArray = self.history
        }
        if let query = query where query.characters.count > 0 {
            self.dataSource = listDataArray.filter { return $0.name.containsString(query) }
        } else {
            self.dataSource = listDataArray
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Setting up destination view controller data source here
        if let scheduleViewController = segue.destinationViewController as? ScheduleViewController where segue.identifier == "ShowSchedule" {
            scheduleViewController.listData = selectedListDataObject
        }
    }
    
    private func selectionDidChange(selected: SelectedSegment.RawValue) {
        switch selected {
            case 0:
                self.selectedSegment = .Favorites
            case 1:
                self.selectedSegment = .Teachers
            case 2:
                self.selectedSegment = .Groups
            case 3:
                self.selectedSegment = .Auditoriums
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
                
                self.tableView.contentInset = contentInset
                self.tableView.scrollIndicatorInsets = contentInset
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CustomTableViewCell.cellHeight
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CustomTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! CustomTableViewCell
        let listDataRecord = dataSource[indexPath.row]
        cell.update(withText: listDataRecord.name, search: searchMode, searchingText: searchText)
        return cell
    }
}

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionViewMenu {
            
            let cell: CollectionViewMenuCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionMenuCell", forIndexPath: indexPath) as! CollectionViewMenuCell
            
            if indexPath.row == 0 {
                
                cell.addImage()
                cell.selected = true
                
                return cell
                
            } else {
                
                if let segment = SelectedSegment(rawValue: indexPath.row) {
                    cell.addTitle(segment.name)
                }
                
                return cell
            }
            
        } else {
            
            let cell: CollectionViewForTableViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("bottomCollectionViewCell", forIndexPath: indexPath) as! CollectionViewForTableViewCell
            
            cell.tableView = self.tableView
            
            if self.history.isEmpty && self.selectedSegment == .Favorites {
                
                cell.selected = true
                
            } else {
                
                cell.selected = false
            }
            
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Scroll to cell in bottom collection view
        if collectionView == self.collectionViewMenu {
            self.selectionDidChange(indexPath.row)
            self.bottomCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
        }
        
        // Set current selected segment
        if let currentSelectedSegment = SelectedSegment(rawValue: indexPath.row) {
            self.selectedSegment = currentSelectedSegment
            UIView.animateWithDuration(0.3, animations: self.containerForSegmentedControl.layoutIfNeeded)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == self.collectionViewMenu {
            
            if indexPath.row == 0 {
                return CGSizeMake(CollectionViewCellConstrains.imageWidth.rawValue + self.calculateIndentBetweenObjectsIntoCollectionVIewCell() - 0.01, CollectionViewConstrains.CollectionViewCellHeight.rawValue)
            } else if indexPath.row == 1 {
                return CGSizeMake(self.calculateLabelWidth(SelectedSegment.Teachers.name) + self.calculateIndentBetweenObjectsIntoCollectionVIewCell() - 1.0, CollectionViewConstrains.CollectionViewCellHeight.rawValue)
            } else if indexPath.row == 2 {
                return CGSizeMake(self.calculateLabelWidth(SelectedSegment.Groups.name) + self.calculateIndentBetweenObjectsIntoCollectionVIewCell() - 1.0, CollectionViewConstrains.CollectionViewCellHeight.rawValue)
            } else {
                return CGSizeMake(self.calculateLabelWidth(SelectedSegment.Auditoriums.name) + self.calculateIndentBetweenObjectsIntoCollectionVIewCell() - 1.0, CollectionViewConstrains.CollectionViewCellHeight.rawValue)
            }
        } else if collectionView == self.bottomCollectionView {
            return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height)
        } else {
            return CGSizeMake(0.0, 0.0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if collectionView == self.collectionViewMenu {
            return 1.0
        } else {
            return 0.0
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if collectionView == self.collectionViewMenu {
            return 1.0
        } else {
            return 0.0
        }
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = self.bottomCollectionView.bounds.size.width
        
        let currentOffset = scrollView.contentOffset.x
        let targetOffset = targetContentOffset.memory.x
        var newTargetOffset: CGFloat = 0.0
        
        if (targetOffset > currentOffset) {
            newTargetOffset = ceil(currentOffset / pageWidth)  * pageWidth
            
        } else {
            newTargetOffset = floor(currentOffset / pageWidth) * pageWidth
        }
        
        if (newTargetOffset < 0) {
            newTargetOffset = 0
            
        } else if (newTargetOffset > scrollView.contentSize.width) {
            newTargetOffset = scrollView.contentSize.width
        }
        
        targetContentOffset.memory.x = currentOffset
        //self.bottomCollectionView.setContentOffset(CGPointMake(newTargetOffset, 0), animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let indexPath = NSIndexPath(forItem: Int(pageNumber), inSection: 0)
        
        self.collectionViewMenu.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .Left)
        
        if indexPath.row == 0 && self.history.isEmpty {
            self.collectionViewForTableViewCell.selected = true
            self.bottomCollectionView.reloadData()
        } else {
            self.collectionViewForTableViewCell.selected = false
            self.bottomCollectionView.reloadData()
        }
        
        if let currentSelectedSegment = SelectedSegment(rawValue: indexPath.row) {
            self.selectedSegment = currentSelectedSegment
            UIView.animateWithDuration(0.3, animations: self.containerForSegmentedControl.layoutIfNeeded)
        }
    }
}

protocol SearchViewControllerDelegate {
    func setListDataObject(listData: ListData)
}

// MARK: - SearchBarViewDelegate

extension SearchViewController: SearchBarViewDelegate {
    
    func refreshContent(searchBarView view: SearchBarView) {
        self.refreshListDataObjects()
        self.tableView.reloadData()
    }
    
    func searchBarView(searchBarView view: SearchBarView, searchWithText text: String?) {
        self.searchText = text
        self.filterDataSourceWithQuery(text)
        self.tableView.reloadData()
    }
    
    func searchBarView(searchBarView view: SearchBarView, searchMode: Bool) {
        self.searchMode = searchMode
        self.tableView.reloadData()
        if searchMode {
            self.tableView.keyboardDismissMode = .Interactive
        } else {
            self.tableView.keyboardDismissMode = .None
        }
    }
}
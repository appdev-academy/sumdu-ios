//
//  SearchViewController.swift
//  SumDU
//
//  Created by Yura Voevodin on 11.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit
import SwiftyJSON

class SearchViewController: UIViewController {
    
    // MARK: - Constants
    
    private let scrollConstraintGroup = ConstraintGroup()
    
    // MARK: - Variables
    
    /// Previous scroll point of the content collection view
    private var previousScrollPoint: CGFloat = 0.0
    
    private var needUpdateUI = true
    
    // Parser for working with server
    private var parser = Parser()
    
    /// Data model
    private var model = DataModel(
        searchText: nil,
        searchMode: false,
        currentState: State.Favorites,
        currentData: [],
        auditoriums: [],
        groups: [],
        teachers: [],
        history: []
    )
    
    // MARK: - UI objects
    
    private let searchBarView = SearchBarView()
    private var menuCollectionView: UICollectionView!
    private let scrollLineView = UIView()
    private let scrollingIndicatorView = UIView()
    private var contentCollectionView: UICollectionView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data
        parser.dataListDelegate = self
        model.updateFromStorage()

        // UI
        initialSetup()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let firstItem = model.history.first {
                let schedule = ScheduleViewController(data: firstItem, fromStorage: true)
                splitViewController?.viewControllers[1] = schedule
            } else {
                let schedule = ScheduleViewController()
                splitViewController?.viewControllers[1] = schedule
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if lists of Teachers, Groups and Auditoriums was updated more than 3 days ago
        let lastUpdatedDate = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKey.LastUpdatedAtDate.key) as? NSDate
        if (lastUpdatedDate == nil) || (lastUpdatedDate != nil && lastUpdatedDate!.compare(NSDate().dateBySubtractingDays(3)) == .OrderedAscending) {
            model.updateFromServer(with: parser)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateMenuScrollIndicator()
        preselectMenuItem()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Invalidate layout of the content collection view when device rotates
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            contentCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - Helpers
    
    private func initialSetup() {
        // Background
        view.backgroundColor = UIColor.whiteColor()
        
        // Search bar
        searchBarView.delegate = self
        view.addSubview(searchBarView)
        constrain(searchBarView, view) {
            searchBarView, superview in
            
            searchBarView.top == superview.top + 30.0
            searchBarView.leading == superview.leading + 14.0
            searchBarView.trailing == superview.trailing
            searchBarView.height == SearchBarView.viewHeight
        }
        // Menu
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        menuCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        menuCollectionView.registerClass(MenuCollectionViewCell.self, forCellWithReuseIdentifier: MenuCollectionViewCell.reuseIdentifier)
        menuCollectionView.registerClass(MenuImageCollectionViewCell.self, forCellWithReuseIdentifier: MenuImageCollectionViewCell.reuseIdentifier)
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.showsVerticalScrollIndicator = false
        menuCollectionView.showsHorizontalScrollIndicator = false
        menuCollectionView.pagingEnabled = true
        menuCollectionView.backgroundColor = UIColor.whiteColor()
        view.addSubview(menuCollectionView)
        constrain(searchBarView, menuCollectionView, view) {
            searchBarView, menuCollectionView, superview in
            
            menuCollectionView.top == searchBarView.bottom
            menuCollectionView.leading == superview.leading
            menuCollectionView.trailing == superview.trailing
            menuCollectionView.height == 62.0
        }
        // Scroll line
        scrollLineView.backgroundColor = Color.separator
        view.addSubview(scrollLineView)
        constrain(scrollLineView, menuCollectionView, view) {
            scrollLineView, menuCollectionView, superview in
            
            scrollLineView.top == menuCollectionView.bottom
            scrollLineView.leading == superview.leading
            scrollLineView.trailing == superview.trailing
            scrollLineView.height == 1.0
        }
        // Scrolling indocator
        scrollingIndicatorView.backgroundColor = Color.textBlack
        view.addSubview(scrollingIndicatorView)
        constrain(scrollingIndicatorView, scrollLineView, view) {
            scrollingIndicatorView, scrollLineView, superview in
            
            scrollingIndicatorView.bottom == scrollLineView.bottom
            scrollingIndicatorView.height == 2.0
        }
        // Content
        let contentFlowLayout = UICollectionViewFlowLayout()
        contentFlowLayout.scrollDirection = .Horizontal
        contentCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: contentFlowLayout)
        contentCollectionView.backgroundColor = UIColor.whiteColor()
        contentCollectionView.registerClass(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.reuseIdentifier)
        contentCollectionView.registerClass(EmptyHistoryCollectionViewCell.self, forCellWithReuseIdentifier: EmptyHistoryCollectionViewCell.reuseIdentifier)
        contentCollectionView.showsVerticalScrollIndicator = false
        contentCollectionView.showsHorizontalScrollIndicator = false
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        contentCollectionView.bounces = false
        view.addSubview(contentCollectionView)
        constrain(scrollLineView, contentCollectionView, view) {
            scrollLineView, contentCollectionView, superview in
            
            contentCollectionView.top == scrollLineView.bottom
            contentCollectionView.leading == superview.leading
            contentCollectionView.trailing == superview.trailing
            contentCollectionView.bottom == superview.bottom
        }
    }
    
    private func labelWidth(text: String) -> CGFloat {
        let size = CGSize(width: CGFloat.max, height: MenuCollectionViewCell.cellHeight)
        let attributes = [NSFontAttributeName: FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 17.0)]
        return text.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil).size.width
    }
    
    /// Calculate spacing between items in menu
    private func interItemSpacing() -> CGFloat {
        let screenWidth = view.bounds.width
        var spacing = screenWidth
        spacing -= MenuImageCollectionViewCell.historyImageSize.width
        spacing -= labelWidth(State.Teachers.name)
        spacing -= labelWidth(State.Auditoriums.name)
        spacing -= labelWidth(State.Groups.name)
        return spacing/4.0
    }
    
    /// Update scroll indicator in menu
    private func updateMenuScrollIndicator() {
        let spacing = interItemSpacing()
        var leading: CGFloat = 0.0
        var width: CGFloat = labelWidth(model.currentState.name)
        let historyImageWidth = MenuImageCollectionViewCell.historyImageSize.width
        switch model.currentState {
            
        case .Favorites:
            leading = spacing/2
            width = historyImageWidth
            
        case .Teachers:
            leading = spacing + spacing/2
            leading += historyImageWidth
            
        case .Groups:
            leading = spacing*2 + spacing/2
            leading += historyImageWidth
            leading += labelWidth(State.Teachers.name)
            
        case .Auditoriums:
            leading = spacing*3 + spacing/2
            leading += historyImageWidth
            leading += labelWidth(State.Teachers.name)
            leading += labelWidth(State.Groups.name)
        }
        constrain(scrollingIndicatorView, view, replace: scrollConstraintGroup) { scrollingIndicatorView, superview in
            scrollingIndicatorView.leading == superview.leading + leading
            scrollingIndicatorView.width == width
        }
    }
    
    /// Select item in menu collection view
    private func preselectMenuItem() {
        let indexPath = NSIndexPath(forItem: model.currentState.rawValue, inSection: 0)
        menuCollectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }
    
    /// Reload current cell with content
    private func reloadCurrentContent() {
        let indexPath = NSIndexPath(forItem: model.currentState.rawValue, inSection: 0)
        contentCollectionView.reloadItemsAtIndexPaths([indexPath])
    }
}

// MARK: - SearchBarViewDelegate

extension SearchViewController: SearchBarViewDelegate {
    
    func refreshContent(searchBarView view: SearchBarView) {
        model.updateFromServer(with: parser)
    }
    
    func searchBarView(searchBarView view: SearchBarView, searchWithText text: String?) {
        model.searchText = text
        reloadCurrentContent()
    }
    
    func searchBarView(searchBarView view: SearchBarView, searchMode: Bool) {
        model.searchMode = searchMode
        reloadCurrentContent()
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Menu
        if collectionView == menuCollectionView {
            if let current = State(rawValue: indexPath.row) {
                model.currentState = current
                
                // Update menu
                updateMenuScrollIndicator()
                UIView.animateWithDuration(0.3, animations: view.layoutIfNeeded)
                
                // Scroll to item collection view with content
                contentCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Menu
        if collectionView == menuCollectionView {
            if indexPath.row != 0, let segment = State(rawValue: indexPath.row) {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MenuCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MenuCollectionViewCell
                cell.update(withTitle: segment.name)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MenuImageCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MenuImageCollectionViewCell
                return cell
            }
        } else {
            // Content
            if indexPath.row == 0 && model.history.count == 0 {
                // Empty history
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EmptyHistoryCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! EmptyHistoryCollectionViewCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ContentCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                cell.contentTableView.delegate = self
                cell.contentTableView.dataSource = self
                cell.contentTableView.reloadData()
                if model.currentData.count == 0 && model.searchMode {
                    cell.showEmptySearch()
                } else {
                    cell.showContent()
                }
                return cell
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Menu
        if collectionView == menuCollectionView, let type = State(rawValue: indexPath.row) {
            let spacing = interItemSpacing()
            let cellHeight = MenuCollectionViewCell.cellHeight
            switch type {
            case .Favorites:
                return CGSize(width: MenuImageCollectionViewCell.historyImageSize.width + spacing, height: cellHeight)
            case .Auditoriums, .Groups, .Teachers:
                return CGSize(width: labelWidth(type.name) + spacing, height: cellHeight)
            }
        } else if collectionView == contentCollectionView {
            // Content
            return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height)
        }
        return CGSizeMake(0.0, 0.0)
    }
}

// MARK: - UIScrollViewDelegate

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Only for UICollectionView with content
        if scrollView != contentCollectionView { return }
        
        let frameWidth = scrollView.bounds.size.width
        let currentOffset = scrollView.contentOffset.x
        let targetOffset = targetContentOffset.memory.x
        var newTargetOffset: CGFloat = 0.0
        
        if (targetOffset > currentOffset) {
            newTargetOffset = ceil(currentOffset/frameWidth)*frameWidth
        } else {
            newTargetOffset = floor(currentOffset/frameWidth)*frameWidth
        }
        if (newTargetOffset < 0) {
            newTargetOffset = 0
        } else if (newTargetOffset > scrollView.contentSize.width) {
            newTargetOffset = scrollView.contentSize.width
        }
        targetContentOffset.memory.x = currentOffset
        contentCollectionView.setContentOffset(CGPointMake(newTargetOffset, 0), animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // Only for UICollectionView with content
        if scrollView != contentCollectionView { return }
        
        // Update state
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let indexPath = NSIndexPath(forItem: Int(pageNumber), inSection: 0)
        if let state = State(rawValue: indexPath.row) { model.currentState = state }
        // Update menu
        updateMenuScrollIndicator()
        UIView.animateWithDuration(0.3, animations: view.layoutIfNeeded)
        preselectMenuItem()
        needUpdateUI = true
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // Only for UICollectionView with content
        if scrollView != contentCollectionView { return }
        
        previousScrollPoint = scrollView.contentOffset.x
        needUpdateUI = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Only for UICollectionView with content
        if scrollView != contentCollectionView { return }
        
        if !needUpdateUI { return }
        
        let currentOffset = scrollView.contentOffset.x
        let frameWidth = scrollView.frame.size.width
        
        if currentOffset > previousScrollPoint {
            let newStateIndex = ceil(currentOffset/frameWidth)
            if let state = State(rawValue: Int(newStateIndex)) { model.currentState = state }
        } else {
            let newStateIndex = floor(currentOffset/frameWidth)
            if let state = State(rawValue: Int(newStateIndex)) { model.currentState = state }
        }
        reloadCurrentContent()
        needUpdateUI = false
    }
}

// MARK: - ParserDataListDelegate

extension SearchViewController: ParserDataListDelegate {
    
    func getRelatedData(response: JSON, requestType: ListDataType) {
        if !UIApplication.sharedApplication().networkActivityIndicatorVisible {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
        var needToUpdateUI = false
        let records = ListData.from(json: response, type: requestType)
        
        switch requestType {
        case .Auditorium:
            model.auditoriums = records
            ListData.saveToStorage(model.auditoriums, forKey: UserDefaultsKey.Auditoriums.key)
            if model.currentState == .Auditoriums { needToUpdateUI = true }
        case .Group:
            model.groups = records
            ListData.saveToStorage(model.groups, forKey: UserDefaultsKey.Groups.key)
            if model.currentState == .Groups { needToUpdateUI = true }
        case .Teacher:
            model.teachers = records
            ListData.saveToStorage(model.teachers, forKey: UserDefaultsKey.Teachers.key)
            if model.currentState == .Teachers { needToUpdateUI = true }
        }
        // Update UI
        if UIApplication.sharedApplication().networkActivityIndicatorVisible {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        if needToUpdateUI { reloadCurrentContent() }
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return model.currentData.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.currentData[section].records.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell
        
        cell.update(with: model.currentData[indexPath.section].records[indexPath.row], search: model.searchMode, searchingText: model.searchText)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SearchTableViewCell.cellHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScheduleSectionHeaderView.viewHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(ScheduleSectionHeaderView.reuseIdentifier) as! ScheduleSectionHeaderView
        headerView.dateLabel.text = String(model.currentData[section].letter)
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let loadFromStorage = model.currentState == .Favorites ? true : false
        let dataItem = model.currentData[indexPath.section].records[indexPath.row]
        let scheduleViewController = ScheduleViewController(data: dataItem, fromStorage: loadFromStorage)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            splitViewController?.viewControllers[1] = scheduleViewController
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            navigationController?.pushViewController(scheduleViewController, animated: true)
        }
        // Remember selected item
        while model.history.count > 50 { model.history.removeFirst() }
        let historyItems = model.history.filter { $0.name == dataItem.name }
        if historyItems.count == 0 { model.history.append(dataItem) }
        ListData.saveToStorage(model.history, forKey: UserDefaultsKey.History.key)
    }
}
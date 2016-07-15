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

struct DataSection {
    var letter: Character
    var records: [ListData]
}

class SearchViewController: UIViewController {
    
    // MARK: - Model
    
    enum State: Int {
        case Favorites
        case Teachers
        case Groups
        case Auditoriums
        
        var name: String {
            switch self {
            case .Favorites: return ""
            case .Teachers: return NSLocalizedString("Teacher", comment: "")
            case .Groups: return NSLocalizedString("Group", comment: "")
            case .Auditoriums: return NSLocalizedString("Auditorium", comment: "")
            }
        }
    }
    
    struct DataModel {
        var auditoriums: [ListData]
        var groups: [ListData]
        var teachers: [ListData]
        var history: [ListData]
        var currentState: State
        
        func currentData(query: String? = nil) -> [ListData] {
            var data: [ListData] = []
            switch currentState {
            case .Auditoriums: data = auditoriums
            case .Favorites: data = history
            case .Groups: data = groups
            case .Teachers: data = teachers
            }
            if let query = query where query.characters.count > 0 {
                data = data.filter { return $0.name.containsString(query) }
            }
            return data
        }
        
        func currentDataBySections(query: String? = nil) -> [DataSection] {
            var recordsBySection: [DataSection] = []
            let allData = self.currentData(query)
            // Get all unique first letters
            var uniqueCharacters = Set<Character>()
            for item in allData {
                if let first = item.name.characters.first {
                   uniqueCharacters.insert(first)
                }
            }
            // Iterate lettres
            for letter in uniqueCharacters.sort() {
                var sectionRecords: [ListData] = []
                for item in allData {
                    if letter == item.name.characters.first {
                        sectionRecords.append(item)
                    }
                }
                recordsBySection.append(DataSection(letter: letter, records: sectionRecords))
            }
            return recordsBySection
        }
        
        /// Load data from storage
        mutating func updateFromStorage() {
            auditoriums = ListData.loadFromStorage(UserDefaultsKey.Auditoriums.key)
            groups = ListData.loadFromStorage(UserDefaultsKey.Groups.key)
            history = ListData.loadFromStorage(UserDefaultsKey.History.key)
            teachers = ListData.loadFromStorage(UserDefaultsKey.Teachers.key)
        }
        
        /// Send request to server for update model data (asynchronously)
        func updateFromServer(with parser: Parser) {
            parser.sendDataRequest(.Auditorium)
            parser.sendDataRequest(.Teacher)
            parser.sendDataRequest(.Group)
        }
    }
    
    // MARK: - Variables
    
    private var parser = Parser()
    private var model = DataModel(auditoriums: [], groups: [], teachers: [], history: [], currentState: .Favorites)
    private var searchMode = false
    private var searchText: String?
    
    // MARK: - Constants
    
    private let scrollConstraintGroup = ConstraintGroup()
    
    // MARK: - UI objects
    
    private let searchBarView = SearchBarView()
    private var menuCollectionView: UICollectionView!
    private let scrollLineView = UIView()
    private let scrollingIndicatorView = UIView()
    private var contentCollectionView: UICollectionView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Update insets for table (not for collection view)
        registerForNotifications()
        
        // Data
        parser.dataListDelegate = self
        model.updateFromStorage()

        // UI
        initialSetup()
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
    
    deinit {
        deregisterFromNotifications()
    }
    
    // MARK: - Notifications
    
    private func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func deregisterFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
            let keyboardInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height,  0.0);
            contentCollectionView.contentInset = keyboardInset
            contentCollectionView.scrollIndicatorInsets = keyboardInset
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        contentCollectionView.contentInset = UIEdgeInsetsZero
        contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    // MARK: - Helpers
    
    private func initialSetup() {
        
        view.backgroundColor = UIColor.whiteColor()
        
        // Search bar
        searchBarView.delegate = self
        view.addSubview(searchBarView)
        constrain(searchBarView, view) { searchBarView, superview in
            
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
        contentCollectionView.scrollEnabled = false
        contentCollectionView.backgroundColor = UIColor.whiteColor()
        contentCollectionView.registerClass(TypeCollectionViewCell.self, forCellWithReuseIdentifier: TypeCollectionViewCell.reuseIdentifier)
        contentCollectionView.showsVerticalScrollIndicator = false
        contentCollectionView.showsHorizontalScrollIndicator = false
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
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
        let screenWidth = min(screenSize.width, screenSize.height)
        var spacing = screenWidth
        spacing -= MenuCollectionViewCell.historyImageSize.width
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
        let historyImageWidth = MenuCollectionViewCell.historyImageSize.width
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
    
    // MARK: - Actions
    
    /// Add new item to the history
    func addToHistory(item: ListData) {
        while model.history.count > 50 { model.history.removeFirst() }
        if !model.history.contains(item) { model.history.append(item) }
        ListData.saveToStorage(model.history, forKey: UserDefaultsKey.History.key)
    }
}

// MARK: - SearchBarViewDelegate

extension SearchViewController: SearchBarViewDelegate {
    
    func refreshContent(searchBarView view: SearchBarView) {
        model.updateFromServer(with: parser)
    }
    
    func searchBarView(searchBarView view: SearchBarView, searchWithText text: String?) {
        searchText = text
        reloadCurrentContent()
    }
    
    func searchBarView(searchBarView view: SearchBarView, searchMode: Bool) {
        self.searchMode = searchMode
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
                
                // Scroll to item in bottom collection view with content
                reloadCurrentContent()
                contentCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MenuCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! MenuCollectionViewCell
            if indexPath.row != 0, let segment = State(rawValue: indexPath.row) {
                cell.update(with: segment.name)
            } else {
                cell.updateWithImage()
            }
            return cell
        } else {
            // Content
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TypeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! TypeCollectionViewCell
            let data = model.currentData(searchText)
            if indexPath.row == 0 && data.count == 0 && !searchMode {
                cell.updateWithImage()
            } else {
                cell.update(with: model.currentDataBySections(searchText), search: searchMode, searchText: searchText, viewController: self)
            }
            return cell
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
                return CGSize(width: MenuCollectionViewCell.historyImageSize.width + spacing, height: cellHeight)
            case .Auditoriums, .Groups, .Teachers:
                return CGSize(width: labelWidth(type.name) + spacing, height: cellHeight)
            }
        } else {
            // Content
            return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = contentCollectionView.bounds.size.width
        let currentOffset = scrollView.contentOffset.x
        let targetOffset = targetContentOffset.memory.x
        var newTargetOffset: CGFloat = 0.0
        if (targetOffset > currentOffset) {
            newTargetOffset = ceil(currentOffset/pageWidth)*pageWidth
        } else {
            newTargetOffset = floor(currentOffset/pageWidth)*pageWidth
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
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let indexPath = NSIndexPath(forItem: Int(pageNumber), inSection: 0)
        if let state = State(rawValue: indexPath.row) {
            model.currentState = state
            // Update menu
            updateMenuScrollIndicator()
            UIView.animateWithDuration(0.3, animations: view.layoutIfNeeded)
            preselectMenuItem()
        }
    }
}

// MARK: - ParserDataListDelegate

extension SearchViewController: ParserDataListDelegate {
    
    func getRelatedData(response: JSON, requestType: ListDataType) {
        
        // TODO: Show request progress
        
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
        if needToUpdateUI { reloadCurrentContent() }
    }
}
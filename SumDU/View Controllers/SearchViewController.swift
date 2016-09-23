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
    
    fileprivate let scrollConstraintGroup = ConstraintGroup()
    
    // MARK: - Variables
    
    fileprivate var contentTableView: UITableView?
    fileprivate var tableViewContentInset = UIEdgeInsets.zero
    
    /// Previous scroll point of the content collection view
    fileprivate var previousScrollPoint: CGFloat = 0.0
    
    fileprivate var needUpdateUI = true
    
    // Parser for working with server
    fileprivate var parser = Parser()
    
    /// Data model
    fileprivate var model = DataModel(
        searchText: nil,
        searchMode: false,
        currentState: State.favorites,
        currentData: [],
        auditoriums: [],
        groups: [],
        teachers: [],
        history: []
    )
    
    // MARK: - UI objects
    
    fileprivate let searchBarView = SearchBarView()
    fileprivate var menuCollectionView: UICollectionView!
    fileprivate let scrollLineView = UIView()
    fileprivate let scrollingIndicatorView = UIView()
    fileprivate var contentCollectionView: UICollectionView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForNotifications()
        
        // Data
        parser.dataListDelegate = self
        model.updateFromStorage()

        // UI
        initialSetup()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let firstItem = model.history.first, let scheduleViewController = splitViewController?.viewControllers.last as? ScheduleViewController {
                scheduleViewController.updateFromStorage(withItem: firstItem)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if lists of Teachers, Groups and Auditoriums was updated more than 3 days ago
        let lastUpdatedDate = UserDefaults.standard.object(forKey: UserDefaultsKey.LastUpdatedAtDate.key) as? Date
        if (lastUpdatedDate == nil) || (lastUpdatedDate != nil && lastUpdatedDate!.compare(Date().dateBySubtractingDays(3)) == .orderedAscending) {
            model.updateFromServer(with: parser)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateMenuScrollIndicator()
        preselectMenuItem()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Invalidate layout of the content collection view when device rotates
        if UIDevice.current.userInterfaceIdiom == .pad {
            contentCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    deinit {
        self.deregisterFromNotifications()
    }
    
    // MARK: - Helpers
    
    fileprivate func initialSetup() {
        // Background
        view.backgroundColor = UIColor.white
        
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
        flowLayout.scrollDirection = .horizontal
        menuCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        menuCollectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: MenuCollectionViewCell.reuseIdentifier)
        menuCollectionView.register(MenuImageCollectionViewCell.self, forCellWithReuseIdentifier: MenuImageCollectionViewCell.reuseIdentifier)
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.showsVerticalScrollIndicator = false
        menuCollectionView.showsHorizontalScrollIndicator = false
        menuCollectionView.isPagingEnabled = true
        menuCollectionView.backgroundColor = UIColor.white
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
        contentFlowLayout.scrollDirection = .horizontal
        contentCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: contentFlowLayout)
        contentCollectionView.backgroundColor = UIColor.white
        contentCollectionView.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.reuseIdentifier)
        contentCollectionView.register(EmptyHistoryCollectionViewCell.self, forCellWithReuseIdentifier: EmptyHistoryCollectionViewCell.reuseIdentifier)
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
    
    fileprivate func labelWidth(_ text: String) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: MenuCollectionViewCell.cellHeight)
        let attributes = [NSFontAttributeName: FontManager.getFont(name: FontName.helveticaNeueMedium, size: 17.0)]
        return text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.width
    }
    
    /// Calculate spacing between items in menu
    fileprivate func interItemSpacing() -> CGFloat {
        let screenWidth = view.bounds.width
        var spacing = screenWidth
        spacing -= MenuImageCollectionViewCell.historyImageSize.width
        spacing -= labelWidth(State.teachers.name)
        spacing -= labelWidth(State.auditoriums.name)
        spacing -= labelWidth(State.groups.name)
        return spacing/4.0
    }
    
    /// Update scroll indicator in menu
    fileprivate func updateMenuScrollIndicator() {
        let spacing = interItemSpacing()
        var leading: CGFloat = 0.0
        var width: CGFloat = labelWidth(model.currentState.name)
        let historyImageWidth = MenuImageCollectionViewCell.historyImageSize.width
        switch model.currentState {
            
        case .favorites:
            leading = spacing/2
            width = historyImageWidth
            
        case .teachers:
            leading = spacing + spacing/2
            leading += historyImageWidth
            
        case .groups:
            leading = spacing*2 + spacing/2
            leading += historyImageWidth
            leading += labelWidth(State.teachers.name)
            
        case .auditoriums:
            leading = spacing*3 + spacing/2
            leading += historyImageWidth
            leading += labelWidth(State.teachers.name)
            leading += labelWidth(State.groups.name)
        }
        constrain(scrollingIndicatorView, view, replace: scrollConstraintGroup) { scrollingIndicatorView, superview in
            scrollingIndicatorView.leading == superview.leading + leading
            scrollingIndicatorView.width == width
        }
    }
    
    /// Select item in menu collection view
    fileprivate func preselectMenuItem() {
        let indexPath = IndexPath(item: model.currentState.rawValue, section: 0)
        menuCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
    }
    
    /// Reload current cell with content
    fileprivate func reloadCurrentContent() {
        let indexPath = IndexPath(item: model.currentState.rawValue, section: 0)
        let cell = contentCollectionView.cellForItem(at: indexPath) as? ContentCollectionViewCell
        if model.currentData.count == 0 && model.searchMode {
            cell?.showEmptySearch()
        } else {
            cell?.showContent()
        }
        contentTableView?.reloadData()
        updateTableContentInset()
    }
    
    fileprivate func updateTableContentInset() {
        contentTableView?.contentInset = tableViewContentInset
        contentTableView?.scrollIndicatorInsets = tableViewContentInset
    }
    
    // MARK: - Notifications
    
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func deregisterFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo: NSDictionary = notification.userInfo as NSDictionary?,
            let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as? NSValue else {
                return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.size.height
        tableViewContentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight,  0.0);
        updateTableContentInset()
    }
    
    func keyboardWillHide(_ notification: Notification) {
        tableViewContentInset = UIEdgeInsets.zero
        updateTableContentInset()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Menu
        if collectionView == menuCollectionView {
            if let current = State(rawValue: (indexPath as NSIndexPath).row) {
                model.currentState = current
                
                // Update menu
                updateMenuScrollIndicator()
                UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
                
                // Scroll to item collection view with content
                contentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Menu
        if collectionView == menuCollectionView {
            if (indexPath as NSIndexPath).row != 0, let segment = State(rawValue: (indexPath as NSIndexPath).row) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.reuseIdentifier, for: indexPath) as! MenuCollectionViewCell
                cell.update(withTitle: segment.name)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuImageCollectionViewCell.reuseIdentifier, for: indexPath) as! MenuImageCollectionViewCell
                return cell
            }
        } else {
            // Content
            if (indexPath as NSIndexPath).row == 0 && model.history.count == 0 {
                // Empty history
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyHistoryCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyHistoryCollectionViewCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.reuseIdentifier, for: indexPath) as! ContentCollectionViewCell
                cell.contentTableView.delegate = self
                cell.contentTableView.dataSource = self
                cell.contentTableView.reloadData()
                contentTableView = cell.contentTableView
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Menu
        if collectionView == menuCollectionView, let type = State(rawValue: (indexPath as NSIndexPath).row) {
            let spacing = interItemSpacing()
            let cellHeight = MenuCollectionViewCell.cellHeight
            switch type {
            case .favorites:
                return CGSize(width: MenuImageCollectionViewCell.historyImageSize.width + spacing, height: cellHeight)
            case .auditoriums, .groups, .teachers:
                return CGSize(width: labelWidth(type.name) + spacing, height: cellHeight)
            }
        } else if collectionView == contentCollectionView {
            // Content
            return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        }
        return CGSize(width: 0.0, height: 0.0)
    }
}

// MARK: - UIScrollViewDelegate

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Only for UICollectionView with content
        if scrollView != contentCollectionView { return }
        
        let frameWidth = scrollView.bounds.size.width
        let currentOffset = scrollView.contentOffset.x
        let targetOffset = targetContentOffset.pointee.x
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
        targetContentOffset.pointee.x = currentOffset
        contentCollectionView.setContentOffset(CGPoint(x: newTargetOffset, y: 0), animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Only for UICollectionView with content
        if scrollView != contentCollectionView { return }
        
        // Update state
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let indexPath = IndexPath(item: Int(pageNumber), section: 0)
        if let state = State(rawValue: (indexPath as NSIndexPath).row) { model.currentState = state }
        // Update menu
        updateMenuScrollIndicator()
        UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
        preselectMenuItem()
        needUpdateUI = true
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Only for UICollectionView with content
        if scrollView != contentCollectionView { return }
        
        previousScrollPoint = scrollView.contentOffset.x
        needUpdateUI = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    
    func getRelatedData(_ response: JSON, requestType: ListDataType) {
        if !UIApplication.shared.isNetworkActivityIndicatorVisible {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        var needToUpdateUI = false
        let records = ListData.from(json: response, type: requestType)
        
        switch requestType {
        case .Auditorium:
            model.auditoriums = records
            ListData.saveToStorage(model.auditoriums, forKey: UserDefaultsKey.Auditoriums.key)
            if model.currentState == .auditoriums { needToUpdateUI = true }
        case .Group:
            model.groups = records
            ListData.saveToStorage(model.groups, forKey: UserDefaultsKey.Groups.key)
            if model.currentState == .groups { needToUpdateUI = true }
        case .Teacher:
            model.teachers = records
            ListData.saveToStorage(model.teachers, forKey: UserDefaultsKey.Teachers.key)
            if model.currentState == .teachers { needToUpdateUI = true }
        }
        // Update UI
        if UIApplication.shared.isNetworkActivityIndicatorVisible {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        if needToUpdateUI { reloadCurrentContent() }
    }
    
    func requestError(_ parser: Parser, localizedError error: String?) {
        if UIApplication.shared.isNetworkActivityIndicatorVisible {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        // TODO: Show alert
//        showAlert(title: NSLocalizedString("Error", comment: ""), message: error)
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.currentData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.currentData[section].records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier, for: indexPath) as! SearchTableViewCell
        
        cell.update(with: model.currentData[(indexPath as NSIndexPath).section].records[(indexPath as NSIndexPath).row], search: model.searchMode, searchingText: model.searchText)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScheduleSectionHeaderView.viewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ScheduleSectionHeaderView.reuseIdentifier) as! ScheduleSectionHeaderView
        headerView.dateLabel.text = String(model.currentData[section].letter)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataItem = model.currentData[(indexPath as NSIndexPath).section].records[(indexPath as NSIndexPath).row]
        
        // For iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Get Schedule controller
            if let scheduleViewController = splitViewController?.viewControllers.last as? ScheduleViewController {
                // Update data
                if model.currentState == .favorites {
                    scheduleViewController.updateFromStorage(withItem: dataItem)
                } else {
                    scheduleViewController.updateFromServer(withItem: dataItem)
                }
            }
            
            // For iPhone
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            let scheduleViewController = ScheduleViewController()
            if model.currentState == .favorites {
                scheduleViewController.updateFromStorage(withItem: dataItem)
            } else {
                scheduleViewController.updateFromServer(withItem: dataItem)
            }
            navigationController?.pushViewController(scheduleViewController, animated: true)
        }

        // Remember selected item
        while model.history.count > 50 { model.history.removeFirst() }
        let historyItems = model.history.filter { $0.name == dataItem.name }
        if historyItems.count == 0 { model.history.append(dataItem) }
        ListData.saveToStorage(model.history, forKey: UserDefaultsKey.History.key)
    }
}

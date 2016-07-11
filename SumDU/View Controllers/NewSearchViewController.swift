//
//  NewSearchViewController.swift
//  SumDU
//
//  Created by Yura Voevodin on 11.07.16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Cartography
import UIKit
import SwiftyJSON

class NewSearchViewController: UIViewController {
    
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
        
        func currentData() -> [ListData] {
            switch currentState {
            case .Auditoriums: return auditoriums
            case .Favorites: return history
            case .Groups: return groups
            case .Teachers: return teachers
            }
        }
        
        /// Load data from storage
        mutating func updateFromStorage() {
            auditoriums = ListData.loadFromStorage(UserDefaultsKey.Auditoriums.key)
            groups = ListData.loadFromStorage(UserDefaultsKey.Groups.key)
            history = ListData.loadFromStorage(UserDefaultsKey.History.key)
            teachers = ListData.loadFromStorage(UserDefaultsKey.Teachers.key)
        }
        
        /// Send request to server for update model data (asynchronously)
        func updateFromServer(withParser parser: Parser) {
            parser.sendDataRequest(.Auditorium)
            parser.sendDataRequest(.Teacher)
            parser.sendDataRequest(.Group)
        }
        
        /// Save updated data
        func saveToStorage() {
            ListData.saveToStorage(auditoriums, forKey: UserDefaultsKey.Auditoriums.key)
            ListData.saveToStorage(groups, forKey: UserDefaultsKey.Groups.key)
            ListData.saveToStorage(teachers, forKey: UserDefaultsKey.Teachers.key)
        }
    }
    
    // MARK: - Variables
    
    var parser = Parser()
    
    var model = DataModel(auditoriums: [], groups: [], teachers: [], history: [], currentState: .Favorites)
    
    // MARK: - Constants
    
    private let screenSize = UIScreen.mainScreen().bounds.size
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
        
        // Data
        parser.dataListDelegate = self
        model.updateFromStorage()

        // UI
        initialSetup()
        updateMenu()
    }
    
    // MARK: - Helpers
    
    private func initialSetup() {
        
        // Search bar
        searchBarView.delegate = self
        view.addSubview(searchBarView)
        constrain(searchBarView, view) { searchBarView, superview in
            
            searchBarView.top == superview.top + 30.0
            searchBarView.leading == superview.leading + 14.0
            searchBarView.trailing == superview.trailing - 14.0
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
        scrollLineView.backgroundColor = lineColor
        view.addSubview(scrollLineView)
        constrain(scrollLineView, menuCollectionView, view) {
            scrollLineView, menuCollectionView, superview in
            
            scrollLineView.top == menuCollectionView.bottom
            scrollLineView.leading == superview.leading
            scrollLineView.trailing == superview.trailing
            scrollLineView.height == 2.0
        }
        
        // Scrolling indocator
        scrollingIndicatorView.backgroundColor = colorForSelectedObjects
        view.addSubview(scrollingIndicatorView)
        constrain(scrollingIndicatorView, menuCollectionView, view) {
            scrollingIndicatorView, menuCollectionView, superview in
            
            scrollingIndicatorView.top == menuCollectionView.bottom
            scrollingIndicatorView.height == 2.0
        }
        
        // Content
        let contentFlowLayout = UICollectionViewFlowLayout()
        contentFlowLayout.scrollDirection = .Horizontal
        contentCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: contentFlowLayout)
        contentCollectionView.backgroundColor = UIColor.whiteColor()
        contentCollectionView.registerClass(TypeCollectionViewCell.self, forCellWithReuseIdentifier: TypeCollectionViewCell.reuseIdentifier)
        contentCollectionView.showsVerticalScrollIndicator = false
        contentCollectionView.showsHorizontalScrollIndicator = false
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        contentCollectionView.backgroundColor = UIColor.grayColor()
        view.addSubview(contentCollectionView)
        constrain(scrollLineView, contentCollectionView, view) {
            scrollLineView, contentCollectionView, superview in
            
            contentCollectionView.top == scrollLineView.bottom
            contentCollectionView.leading == superview.leading
            contentCollectionView.trailing == superview.trailing
            contentCollectionView.bottom == superview.bottom
        }
    }
    
    private func labelWidth(label: String) -> CGFloat {
        return label.boundingRectWithSize(CGSize(width: DBL_MAX, height: DBL_MAX), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: titleTextFont], context: nil).size.width
    }
    
    private func interItemSpacing() -> CGFloat {
        let screenWidth = min(screenSize.width, screenSize.height)
        var indent = screenWidth
        indent -= MenuCollectionViewCell.historyImageSize.width
        indent -= labelWidth(State.Teachers.name)
        indent -= labelWidth(State.Auditoriums.name)
        indent -= labelWidth(State.Groups.name)
        return indent/4.0
    }
    
    private func scroll(to newLeading: CGFloat, newWidth: CGFloat) {
        constrain(scrollingIndicatorView, view, replace: scrollConstraintGroup) { scrollingIndicatorView, superview in
            
            scrollingIndicatorView.leading == superview.leading + newLeading
            scrollingIndicatorView.width == newWidth
        }
        UIView.animateWithDuration(0.3, animations: view.layoutIfNeeded)
    }
    
    private func updateMenu() {
        let spacing = interItemSpacing()
        var leading: CGFloat = 0.0
        var width: CGFloat = labelWidth(model.currentState.name)
        let historyImageWidth = MenuCollectionViewCell.historyImageSize.width
        switch model.currentState {
            
        case .Favorites:
            leading = spacing/2
            width = historyImageWidth
            
        case .Teachers:
            leading = spacing
            leading += historyImageWidth
            
        case .Groups:
            leading = spacing*2
            leading += historyImageWidth
            leading += labelWidth(State.Teachers.name)
            
        case .Auditoriums:
            leading = spacing*3
            leading += historyImageWidth
            leading += labelWidth(State.Teachers.name)
            leading += labelWidth(State.Groups.name)
        }
        scroll(to: leading, newWidth: width)
        let indexPath = NSIndexPath(forItem: model.currentState.rawValue, inSection: 0)
        menuCollectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
    }
}

// MARK: - SearchBarViewDelegate

extension NewSearchViewController: SearchBarViewDelegate {
    
    func refreshContent(searchBarView view: SearchBarView) {
        model.updateFromServer(withParser: parser)
        // TODO: Implement logic
    }
    
    func searchBarView(searchBarView view: SearchBarView, searchWithText text: String?) {
        // TODO: Implement logic
    }
    
    func searchBarView(searchBarView view: SearchBarView, searchMode: Bool) {
        // TODO: Implement logic
    }
}

// MARK: - UICollectionViewDelegate

extension NewSearchViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Scroll to item in bottom collection view
        if collectionView == menuCollectionView {
            contentCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            
            // Update current
            if let current = State(rawValue: indexPath.row) {
                model.currentState = current
                updateMenu()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension NewSearchViewController: UICollectionViewDataSource {
    
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
            cell.update(with: model.currentData())
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewSearchViewController: UICollectionViewDelegateFlowLayout {
    
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

extension NewSearchViewController: UIScrollViewDelegate {
    
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
            updateMenu()
        }
    }
}

// MARK: - ParserDataListDelegate

extension NewSearchViewController: ParserDataListDelegate {
    
    func getRelatedData(response: JSON, requestType: ListDataType) {
        
        // TODO: Show progress with Quack
        
        var needToUpdateUI = false
        let records = ListData.from(json: response, type: requestType)
        switch requestType {
        case .Auditorium:
            model.auditoriums = records
            if model.currentState == .Auditoriums {
                needToUpdateUI = true
            }
        case .Group:
            model.groups = records
            if model.currentState == .Groups {
                needToUpdateUI = true
            }
        case .Teacher:
            model.teachers = records
            if model.currentState == .Teachers {
                needToUpdateUI = true
            }
        }
        model.saveToStorage()
        
        // Update UI
        if needToUpdateUI {
            let indexPath = NSIndexPath(forItem: model.currentState.rawValue, inSection: 0)
            contentCollectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }
}
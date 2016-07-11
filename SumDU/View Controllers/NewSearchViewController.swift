//
//  NewSearchViewController.swift
//  SumDU
//
//  Created by Yura Voevodin on 11.07.16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Cartography
import UIKit

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
    
    // MARK: - Constants
    
    private let screenSize = UIScreen.mainScreen().bounds.size
    
    // MARK: - UI objects
    
    private let searchBarView = SearchBarView()
    private var menuCollectionView: UICollectionView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
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
}

// MARK: - SearchBarViewDelegate

extension NewSearchViewController: SearchBarViewDelegate {
    
    func refreshContent(searchBarView view: SearchBarView) {
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
        
        // TODO: Implement logic
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
            
            if indexPath.row != 0 {
                if let segment = State(rawValue: indexPath.row) {
                    cell.update(with: segment.name)
                }
            } else {
                cell.updateWithImage()
            }
            return cell
            
        } else {
            // Content
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TypeCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! TypeCollectionViewCell
            
            // TODO: Implement logic
            
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
//
//  TypeCollectionViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit

class TypeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(TypeCollectionViewCell.self)"
    
    // MARK: - Variables
    
    private var recordsBySection: [DataSection] = []
    private var search = false
    private var searchText: String?
    private var viewController: SearchViewController?
    
    // MARK: - UI Objects
    
    let typeTableViewController = TypeTableViewController()
    private let historyImage = UIImageView()
    private let emptyHistoryLabel = UILabel()
    private let emptyHistoryDescriptionLabel = UILabel()
    private let notFoudLabel = UILabel()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // History image
        historyImage.hidden = true
        historyImage.contentMode = .ScaleAspectFill
        historyImage.clipsToBounds = true
        contentView.addSubview(historyImage)
        historyImage.image = UIImage(named: "empty_history")
        constrain(historyImage, contentView) {
            historyImage, superview in
            
            historyImage.top == superview.top + 46.0
            historyImage.centerX == superview.centerX
        }
        // History label
        emptyHistoryLabel.text = NSLocalizedString("History is empty", comment: "")
        emptyHistoryLabel.hidden = true
        emptyHistoryLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 20)
        emptyHistoryLabel.textColor = Color.textNormal
        emptyHistoryLabel.textAlignment = .Center
        contentView.addSubview(emptyHistoryLabel)
        constrain(historyImage, emptyHistoryLabel, contentView) {
            historyImage, emptyHistoryLabel, superview in
            
            emptyHistoryLabel.top == historyImage.bottom + 35.0
            emptyHistoryLabel.leading == superview.leading + 14.0
            emptyHistoryLabel.trailing == superview.trailing - 14.0
        }
        // History description
        emptyHistoryDescriptionLabel.text = NSLocalizedString("Swipe the screen left and right to navigate between the main sections and the search schedule", comment: "")
        emptyHistoryDescriptionLabel.hidden = true
        emptyHistoryDescriptionLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 15.0)
        emptyHistoryDescriptionLabel.textColor = Color.textLight
        emptyHistoryDescriptionLabel.textAlignment = .Center
        emptyHistoryDescriptionLabel.numberOfLines = 0
        contentView.addSubview(emptyHistoryDescriptionLabel)
        constrain(emptyHistoryDescriptionLabel, emptyHistoryLabel, contentView) {
            emptyHistoryDescriptionLabel, emptyHistoryLabel, superview in
            
            emptyHistoryDescriptionLabel.top == emptyHistoryLabel.bottom + 8.0
            emptyHistoryDescriptionLabel.leading == superview.leading + 33.0
            emptyHistoryDescriptionLabel.trailing == superview.trailing - 33.0
            emptyHistoryDescriptionLabel.bottom == superview.bottom - 14.0
        }
        // Table
        typeTableViewController.delegate = self
        contentView.addSubview(typeTableViewController.tableView)
        constrain(typeTableViewController.tableView, contentView) { tableView, superview in
            tableView.edges == superview.edges
        }
        // Not found
        notFoudLabel.text = NSLocalizedString("No data found", comment: "")
        notFoudLabel.hidden = true
        notFoudLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 20)
        notFoudLabel.textColor = Color.textNormal
        notFoudLabel.textAlignment = .Center
        contentView.addSubview(notFoudLabel)
        constrain(notFoudLabel, contentView) {
            notFoudLabel, superview in
            
            notFoudLabel.top == superview.top + 66.0
            notFoudLabel.leading == superview.leading + 14.0
            notFoudLabel.trailing == superview.trailing - 14.0
        }
    }
    
    // MARK: - Helpers
    
    private func showEmptyHistory() {
        notFoudLabel.hidden = true
        emptyHistoryLabel.hidden = false
        emptyHistoryDescriptionLabel.hidden = false
        historyImage.hidden = false
        typeTableViewController.tableView.hidden = true
    }
    
    private func showEmptySearch() {
        notFoudLabel.hidden = false
        emptyHistoryLabel.hidden = true
        emptyHistoryDescriptionLabel.hidden = true
        historyImage.hidden = true
        typeTableViewController.tableView.hidden = true
    }
    
    private func showContent() {
        notFoudLabel.hidden = true
        emptyHistoryLabel.hidden = true
        emptyHistoryDescriptionLabel.hidden = true
        historyImage.hidden = true
        typeTableViewController.tableView.hidden = false
    }
    
    // MARK: - Interface
    
    func updateWithImage() {
        showEmptyHistory()
    }
    
    func update(with data: [DataSection], search: Bool, searchText: String?, viewController: SearchViewController) {
        if data.count == 0 && search {
            showEmptySearch()
        } else {
            showContent()
            self.viewController = viewController
            self.search = search
            self.searchText = searchText
            self.recordsBySection = data
            typeTableViewController.update(with: data, search: search, searchText: searchText)
        }
    }
}

// MARK: - TypeTableViewControllerDelegate

extension TypeCollectionViewCell: TypeTableViewControllerDelegate {
    
    func typeTableViewController(typeTableViewController: TypeTableViewController, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let dataItem = recordsBySection[indexPath.section].records[indexPath.row]
        let scheduleViewController = ScheduleViewController(data: dataItem)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            viewController?.splitViewController?.viewControllers[1] = scheduleViewController
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            viewController?.navigationController?.pushViewController(scheduleViewController, animated: true)
        }
        // Remember selected item
        viewController?.addToHistory(dataItem)
    }
}
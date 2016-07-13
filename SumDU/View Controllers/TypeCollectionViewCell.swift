//
//  TypeCollectionViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Cartography
import UIKit

class TypeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(TypeCollectionViewCell.self)"
    
    // MARK: - Variables
    
    private var data: [ListData] = []
    private var search = false
    private var searchText: String?
    private var viewController: NewSearchViewController?
    
    // MARK: - UI Objects
    
    private let tableView = UITableView()
    private let historyImage = UIImageView()
    private let emptyHistoryLabel = UILabel()
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
        constrain(historyImage, contentView) { historyImage, superview in
            historyImage.top == superview.top + 66.0
            historyImage.centerX == superview.centerX
        }
        // History label
        emptyHistoryLabel.hidden = true
        emptyHistoryLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 20)
        emptyHistoryLabel.textColor = Color.textColorNormal
        emptyHistoryLabel.textAlignment = .Center
        contentView.addSubview(emptyHistoryLabel)
        constrain(historyImage, emptyHistoryLabel, contentView) { historyImage, emptyHistoryLabel, superview in
            emptyHistoryLabel.top == historyImage.bottom + 55.0
            emptyHistoryLabel.leading == superview.leading + 14.0
            emptyHistoryLabel.trailing == superview.trailing - 14.0
        }
        emptyHistoryLabel.text = NSLocalizedString("History is empty", comment: "")
        // Table
        tableView.registerClass(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.delegate = self
        tableView.dataSource = self
        contentView.addSubview(tableView)
        constrain(tableView, contentView) { tableView, superview in
            tableView.edges == superview.edges
        }
        // Not found
        notFoudLabel.hidden = true
        notFoudLabel.font = FontManager.getFont(name: FontName.HelveticaNeueMedium, size: 20)
        notFoudLabel.textColor = Color.textColorNormal
        notFoudLabel.textAlignment = .Center
        contentView.addSubview(notFoudLabel)
        constrain(notFoudLabel, contentView) { notFoudLabel, superview in
            notFoudLabel.center == superview.center
        }
        notFoudLabel.text = NSLocalizedString("No data found", comment: "")
    }
    
    // MARK: - Helpers
    
    private func showEmptyHistory() {
        notFoudLabel.hidden = true
        emptyHistoryLabel.hidden = false
        historyImage.hidden = false
        tableView.hidden = true
    }
    
    private func showEmptySearch() {
        notFoudLabel.hidden = false
        emptyHistoryLabel.hidden = true
        historyImage.hidden = true
        tableView.hidden = true
    }
    
    private func showContent() {
        notFoudLabel.hidden = true
        emptyHistoryLabel.hidden = true
        historyImage.hidden = true
        tableView.hidden = false
    }
    
    // MARK: - Interface
    
    func update(with data: [ListData], search: Bool, searchText: String?, viewController: NewSearchViewController) {
        if data.count == 0 && search {
            showEmptySearch()
        } else {
            showContent()
            self.viewController = viewController
            self.search = search
            self.searchText = searchText
            self.data = data
            tableView.reloadData()
        }
    }
    
    func updateWithImage() {
        showEmptyHistory()
    }
}

// MARK: - UITableViewDataSource

extension TypeCollectionViewCell: UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SearchTableViewCell.cellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell
        cell.update(with: data[indexPath.row], search: search, searchingText: searchText)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TypeCollectionViewCell: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dataItem = data[indexPath.row]
        let scheduleViewController = ScheduleViewController(data: dataItem)
        viewController?.navigationController?.pushViewController(scheduleViewController, animated: true)
        
        // Remember selected item
        viewController?.addToHistory(dataItem)
    }
}
//
//  TypeTableViewController.swift
//  SumDU
//
//  Created by Yura Voevodin on 15.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import UIKit

protocol TypeTableViewControllerDelegate {
    func typeTableViewController(typeTableViewController: TypeTableViewController, didSelectItemAtIndexPath indexPath: NSIndexPath)
}

class TypeTableViewController: UITableViewController {
    
    // MARK: - Variables
    
    var delegate: TypeTableViewControllerDelegate?
    private var recordsBySection: [DataSection] = []
    private var search = false
    private var searchText: String?
    
    // MARK: - Initialization
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(ScheduleSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: ScheduleSectionHeaderView.reuseIdentifier)
        tableView.registerClass(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .None
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return recordsBySection.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsBySection[section].records.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell
        
        cell.update(with: recordsBySection[indexPath.section].records[indexPath.row], search: search, searchingText: searchText)
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SearchTableViewCell.cellHeight
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScheduleSectionHeaderView.viewHeight
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(ScheduleSectionHeaderView.reuseIdentifier) as! ScheduleSectionHeaderView
        headerView.dateLabel.text = String(recordsBySection[section].letter)
        return headerView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.typeTableViewController(self, didSelectItemAtIndexPath: indexPath)
    }
    
    // MARK: - Interface
    
    func update(with data: [DataSection], search: Bool, searchText: String?) {
        self.recordsBySection = data
        self.search = search
        self.searchText = searchText
        tableView.reloadData()
    }
}
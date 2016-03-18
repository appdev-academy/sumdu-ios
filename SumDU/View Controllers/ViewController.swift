//
//  ViewController.swift
//  SumDU
//
//  Created by Maksym Skliarov on 11/21/15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, SearchViewControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var containerForSearchVC: UIView!
    @IBOutlet weak var containerForScheduleVC: UIView!
    
    
    // MARK: - Variables
    
    var scheduleViewController: ScheduleViewController?
    var searchViewController: SearchViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setListDataObject(listData: ListData) {
        self.scheduleViewController?.listData = listData
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "searchSegue" {
            if let navigationController = segue.destinationViewController as? UINavigationController {
                self.searchViewController = navigationController.viewControllers.first as? SearchViewController
                self.searchViewController?.delegate = self
            }
        } else if segue.identifier == "ScheduleSegue" {
            if let navigationController = segue.destinationViewController as? UINavigationController {
                if let scheduleViewController = navigationController.viewControllers.first as? ScheduleViewController {
                    self.scheduleViewController = scheduleViewController
                }
            }
        }
    }
}
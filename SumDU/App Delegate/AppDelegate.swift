//
//  AppDelegate.swift
//  SumDU
//
//  Created by Maksym Skliarov on 11/21/15.
//  Copyright © 2015 AppDevAcademy. All rights reserved.
//

import CoreDuck
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Initialize CoreData stack
    let _ = CoreDuck.quack
    CoreDuck.printErrors = true
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    
    if UIDevice.current.userInterfaceIdiom == .pad, let window = self.window {
      let searchViewController = SearchViewController()
      searchViewController.fetchData()
      
      let scheduleViewController = ScheduleViewController()
      let splitViewController = UISplitViewController()
      splitViewController.viewControllers = [searchViewController, scheduleViewController]
      splitViewController.preferredDisplayMode = .allVisible
      splitViewController.minimumPrimaryColumnWidth = 360.0
      splitViewController.maximumPrimaryColumnWidth = 360.0
      window.rootViewController = splitViewController
      window.makeKeyAndVisible()
    }
    if UIDevice.current.userInterfaceIdiom == .phone, let window = self.window  {
      let searchViewController = SearchViewController()
      searchViewController.fetchData()
      
      let navigationController = UINavigationController(rootViewController: searchViewController)
      navigationController.isNavigationBarHidden = true
      window.rootViewController = navigationController
      window.makeKeyAndVisible()
    }
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    
    // Get date of last update for Teachers, Groups and Auditoriums
    let lastUpdated = UserDefaults.standard.object(forKey: UserDefaultsKey.LastUpdatedAtDate.key) as? Date
    
    // Import first time
    guard let updatedDate = lastUpdated else {
      NetworkingManager.updateListsOfAuditoriumsGroupsAndTeachers()
      return
    }
    
    // Update if it's been more than 3 days ago
    if updatedDate.isLessThanDate(Date().minusDays(3)) {
      NetworkingManager.updateListsOfAuditoriumsGroupsAndTeachers()
    }
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

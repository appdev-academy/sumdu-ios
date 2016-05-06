//
//  SearchBarContainer.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/4/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class SearchBarContainer: UIView {
    
    
    // MARK: - Variables
    
    private var group = ConstraintGroup()
    
    private var isEditingMode = false {
        
        didSet {
            
            self.removeCancelButton()
            self.removeRefreshButton()
            
            if self.isEditingMode {
                
                self.addRCancelButton()
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.containerForButtons.layoutIfNeeded()
                })
                
            } else {
                
                self.addRefreshButton()
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.containerForButtons.layoutIfNeeded()
                    
                })
                self.searchBar.resignFirstResponder()
            }
        }
    }
    
    // MARK: - UIObjects
    
    var searchBar = SearchBar(frame: CGRectZero)
    private var containerForButtons = UIView(frame: CGRectZero)
    private var refreshBarButton = UIButton(frame: CGRectZero)
    private var cancelBarButton = UIButton(frame: CGRectZero)
    private var inactiveSearchButtonImage = UIImage(named: "InactiveRefreshButton")
    private var inactiveCancelButtonImage = UIImage(named: "InactiveCancelButton")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.searchBar.layer.cornerRadius = 6.0
        //self.searchBar.textField.addTarget(self, action: #selector(TopBarContainer.textFieldEditingChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        self.addSubview(self.searchBar)
        self.addSubview(self.containerForButtons)
        
        self.addRefreshButton()
        
        self.setupConstraints()
    }
    
    private func addRefreshButton() {
        
        self.refreshBarButton = UIButton(frame: CGRect(x: self.containerForButtons.layer.frame.width/2, y: self.containerForButtons.layer.frame.height/2, width: 0.0, height: 0.0))
        self.refreshBarButton.setImage(self.inactiveSearchButtonImage, forState: .Normal)
        self.containerForButtons.addSubview(self.refreshBarButton)
        
        constrain(self.refreshBarButton, replace: self.group) {
            refreshBarButton in
            
            refreshBarButton.width == refreshBarButton.superview!.width
            refreshBarButton.height == refreshBarButton.superview!.height
            refreshBarButton.trailing == refreshBarButton.superview!.trailing
            refreshBarButton.centerY == refreshBarButton.superview!.centerY
        }
    }
    
    private func addRCancelButton() {
        
        self.cancelBarButton = UIButton(frame: CGRect(x: self.containerForButtons.layer.frame.width/2, y: self.containerForButtons.layer.frame.height/2, width: 0.0, height: 0.0))
        self.cancelBarButton.setImage(self.inactiveCancelButtonImage, forState: .Normal)
        self.containerForButtons.addSubview(self.cancelBarButton)
        
        constrain(self.cancelBarButton, replace: self.group) {
            cancelBarButton in
            
            cancelBarButton.width == cancelBarButton.superview!.width
            cancelBarButton.height == cancelBarButton.superview!.height
            cancelBarButton.trailing == cancelBarButton.superview!.trailing
            cancelBarButton.centerY == cancelBarButton.superview!.centerY
        }
    }
    
    private func removeRefreshButton() {
        
        if self.refreshBarButton.superview == self.containerForButtons {
            self.refreshBarButton.removeFromSuperview()
        }
    }
    
    private func removeCancelButton() {
        
        if self.cancelBarButton.superview == self.containerForButtons {
            self.cancelBarButton.removeFromSuperview()
        }
    }
    
    private func setupConstraints() {
        
        constrain(self.searchBar, self.containerForButtons) {
            searchBar, containerForButtons in
            
            searchBar.leading == searchBar.superview!.leading
            searchBar.top == searchBar.superview!.top
            searchBar.trailing == containerForButtons.leading - 10
            searchBar.bottom == searchBar.superview!.bottom

            containerForButtons.width == 24.0
            containerForButtons.height == 24.0
            containerForButtons.trailing == containerForButtons.superview!.trailing
            containerForButtons.centerY == containerForButtons.superview!.centerY
        }
    }
}
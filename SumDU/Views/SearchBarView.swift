//
//  SearchBarView.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/4/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

protocol SearchBarViewDelegate {
    func refreshContent(searchBarView view: SearchBarView)
    func searchBarView(searchBarView view: SearchBarView, searchWithText text: String?)
    func searchBarView(searchBarView view: SearchBarView, searchMode: Bool)
}

class SearchBarView: UIView {
    
    // MARK: - Variables
    
    var delegate: SearchBarViewDelegate?
    
    private var isEditingMode = false {
        didSet {
            self.delegate?.searchBarView(searchBarView: self, searchMode: self.isEditingMode)
            self.cancelBarButton.removeFromSuperview()
            self.refreshBarButton.removeFromSuperview()
            self.isEditingMode ? self.addCancelButton() : self.addRefreshButton()
            UIView.animateWithDuration(0.3, animations: {
                self.containerForButtons.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - UIObjects
    
    // Left
    private let searchContainer = UIView()
    private let textField = SearchTextField()
    private let imageView = UIImageView()
    
    // Right
    private let containerForButtons = UIView()
    private let refreshBarButton = UIButton()
    private let cancelBarButton = UIButton()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Right container
        self.addSubview(self.containerForButtons)
        constrain(self.containerForButtons, self) { containerForButtons, superview in
            
            containerForButtons.width == 24.0
            containerForButtons.height == 24.0
            containerForButtons.trailing == superview.trailing
            containerForButtons.centerY == superview.centerY
        }

        // Left container
        self.searchContainer.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 245.0/255, alpha: 1.0)
        self.searchContainer.layer.cornerRadius = 6.0
        self.addSubview(self.searchContainer)
        constrain(self.searchContainer, self.containerForButtons, self) {
            searchContainer, containerForButtons, superview in
            
            searchContainer.top == superview.top
            searchContainer.leading == superview.leading
            searchContainer.trailing == containerForButtons.leading - 10
            searchContainer.bottom == superview.bottom
        }

        // Magnifying glass
        self.imageView.image = UIImage(named: "MagnifyingGlass")
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.layer.zPosition = 2.0
        self.searchContainer.addSubview(self.imageView)
        constrain(self.imageView, self.searchContainer) { imageView, superview in
            
            imageView.width == 24.0
            imageView.height == 24.0
            imageView.leading == superview.leading + 10.0
            imageView.centerY == superview.centerY
        }

        // Search text field
        self.textField.delegate = self
        self.searchContainer.addSubview(self.textField)
        constrain(self.imageView, self.textField, self.searchContainer) { imageView, textField, superview in
            
            textField.leading == imageView.trailing + 10.0
            textField.trailing == superview.trailing - 1.0
            textField.height == 44.0
            textField.centerY == superview.centerY
        }
        
        // Default
        self.addRefreshButton()
    }
    
    private func addRefreshButton() {
        self.refreshBarButton.addTarget(self, action: #selector(refreshButtonPressed), forControlEvents: .TouchUpInside)
        self.refreshBarButton.setImage(UIImage(named: "InactiveRefreshButton"), forState: .Normal)
        self.containerForButtons.addSubview(self.refreshBarButton)
        constrain(self.refreshBarButton, self.containerForButtons) { refreshBarButton, superview in
            refreshBarButton.edges == superview.edges
        }
    }
    
    private func addCancelButton() {
        self.cancelBarButton.addTarget(self, action: #selector(cancelButtonPressed), forControlEvents: .TouchUpInside)
        self.cancelBarButton.setImage(UIImage(named: "InactiveCancelButton"), forState: .Normal)
        self.containerForButtons.addSubview(self.cancelBarButton)
        constrain(self.cancelBarButton, self.containerForButtons) { cancelBarButton, superview in
            cancelBarButton.edges == superview.edges
        }
    }
    
    func cancelButtonPressed() {
        self.isEditingMode = false
        self.textField.text = ""
        self.delegate?.searchBarView(searchBarView: self, searchWithText: nil)
        self.textField.resignFirstResponder()
    }
    
    func refreshButtonPressed() {
        self.delegate?.refreshContent(searchBarView: self)
    }
}

extension SearchBarView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.isEditingMode = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.characters.count > 0 {
            self.isEditingMode = true
        } else {
            self.isEditingMode = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText: NSString = textField.text ?? ""
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        self.delegate?.searchBarView(searchBarView: self, searchWithText: newText as String)
        return true
    }
}
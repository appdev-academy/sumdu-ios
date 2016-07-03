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
            delegate?.searchBarView(searchBarView: self, searchMode: isEditingMode)
            cancelBarButton.removeFromSuperview()
            refreshBarButton.removeFromSuperview()
            isEditingMode ? addCancelButton() : addRefreshButton()
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
        addSubview(containerForButtons)
        constrain(containerForButtons, self) { containerForButtons, superview in
            
            containerForButtons.width == 24.0
            containerForButtons.height == 24.0
            containerForButtons.trailing == superview.trailing
            containerForButtons.centerY == superview.centerY
        }

        // Left container
        searchContainer.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 245.0/255, alpha: 1.0)
        searchContainer.layer.cornerRadius = 6.0
        addSubview(searchContainer)
        constrain(searchContainer, containerForButtons, self) {
            searchContainer, containerForButtons, superview in
            
            searchContainer.top == superview.top
            searchContainer.leading == superview.leading
            searchContainer.trailing == containerForButtons.leading - 10
            searchContainer.bottom == superview.bottom
        }

        // Magnifying glass
        imageView.image = UIImage(named: "MagnifyingGlass")
        imageView.contentMode = .ScaleAspectFit
        imageView.layer.zPosition = 2.0
        searchContainer.addSubview(imageView)
        constrain(imageView, searchContainer) { imageView, superview in
            
            imageView.width == 24.0
            imageView.height == 24.0
            imageView.leading == superview.leading + 10.0
            imageView.centerY == superview.centerY
        }

        // Search text field
        textField.delegate = self
        searchContainer.addSubview(textField)
        constrain(imageView, textField, searchContainer) { imageView, textField, superview in
            
            textField.leading == imageView.trailing + 10.0
            textField.trailing == superview.trailing - 1.0
            textField.height == 44.0
            textField.centerY == superview.centerY
        }
        
        // Default
        addRefreshButton()
    }
    
    private func addRefreshButton() {
        refreshBarButton.addTarget(self, action: #selector(refreshButtonPressed), forControlEvents: .TouchUpInside)
        refreshBarButton.setImage(UIImage(named: "InactiveRefreshButton"), forState: .Normal)
        containerForButtons.addSubview(refreshBarButton)
        constrain(refreshBarButton, containerForButtons) { refreshBarButton, superview in
            refreshBarButton.edges == superview.edges
        }
    }
    
    private func addCancelButton() {
        cancelBarButton.addTarget(self, action: #selector(cancelButtonPressed), forControlEvents: .TouchUpInside)
        cancelBarButton.setImage(UIImage(named: "InactiveCancelButton"), forState: .Normal)
        containerForButtons.addSubview(cancelBarButton)
        constrain(cancelBarButton, containerForButtons) { cancelBarButton, superview in
            cancelBarButton.edges == superview.edges
        }
    }
    
    func cancelButtonPressed() {
        isEditingMode = false
        textField.text = ""
        delegate?.searchBarView(searchBarView: self, searchWithText: nil)
        textField.resignFirstResponder()
    }
    
    func refreshButtonPressed() {
        delegate?.refreshContent(searchBarView: self)
    }
}

extension SearchBarView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        isEditingMode = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.characters.count > 0 {
            isEditingMode = true
        } else {
            isEditingMode = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText: NSString = textField.text ?? ""
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        delegate?.searchBarView(searchBarView: self, searchWithText: newText as String)
        return true
    }
}
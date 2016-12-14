//
//  SearchBarView.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/4/16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import Cartography
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol SearchBarViewDelegate {
  func refreshContent(searchBarView view: SearchBarView)
  func searchBarView(searchBarView view: SearchBarView, searchWithText text: String?)
  func searchBarView(searchBarView view: SearchBarView, searchMode: Bool)
}

class SearchBarView: UIView {
  
  // MARK: - Constants
  
  static let viewHeight: CGFloat = 44.0
  
  // MARK: - Variables
  
  var delegate: SearchBarViewDelegate?
  
  fileprivate var isEditingMode = false {
    didSet {
      delegate?.searchBarView(searchBarView: self, searchMode: isEditingMode)
      if isEditingMode {
        refreshButton.isHidden = true
        cancelButton.isHidden = false
        cancelButton.alpha = 0.0
      } else {
        cancelButton.isHidden = true
        refreshButton.isHidden = false
        refreshButton.alpha = 0.0
        
      }
      UIView.animate(withDuration: 0.5, animations: {
        if self.isEditingMode {
          self.cancelButton.alpha = 1.0
        } else {
          self.refreshButton.alpha = 1.0
        }
      })
    }
  }
  
  // MARK: - UI Objects
  
  // Left
  fileprivate let searchContainer = UIView()
  fileprivate let textField = SearchTextField()
  fileprivate let imageView = UIImageView()
  
  // Right
  fileprivate let containerForButtons = UIView()
  fileprivate let refreshButton = RefreshButton()
  fileprivate let cancelButton = UIButton()
  
  // MARK: - Initialization
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    // Right container
    addSubview(containerForButtons)
    constrain(containerForButtons, self) { containerForButtons, superview in
      
      containerForButtons.width == 52.0
      containerForButtons.height == 44.0
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
      searchContainer.trailing == containerForButtons.leading
      searchContainer.bottom == superview.bottom
    }
    // Magnifying glass
    imageView.image = UIImage(named: "search_normal")
    imageView.contentMode = .scaleAspectFit
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
      textField.trailing == superview.trailing
      textField.height == 44.0
      textField.centerY == superview.centerY
    }
    // Refresh
    refreshButton.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
    containerForButtons.addSubview(refreshButton)
    constrain(refreshButton, containerForButtons) { refreshBarButton, superview in
      refreshBarButton.edges == superview.edges
    }
    // Cancel
    cancelButton.isHidden = true
    cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    cancelButton.setImage(UIImage(named: "cancel_normal"), for: UIControlState())
    cancelButton.setImage(UIImage(named: "cancel_pressed"), for: .selected)
    containerForButtons.addSubview(cancelButton)
    constrain(cancelButton, containerForButtons) { cancelBarButton, superview in
      cancelBarButton.edges == superview.edges
    }
  }
  
  func cancelButtonPressed() {
    isEditingMode = false
    textField.text = ""
    textField.resignFirstResponder()
  }
  
  func refreshButtonPressed() {
    delegate?.refreshContent(searchBarView: self)
  }
}

// MARK: - UITextFieldDelegate

extension SearchBarView: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    isEditingMode = true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField.text?.characters.count > 0 {
      isEditingMode = true
    } else if isEditingMode {
      isEditingMode = false
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var newText: NSString = textField.text as NSString? ?? ""
    newText = newText.replacingCharacters(in: range, with: string) as NSString
    delegate?.searchBarView(searchBarView: self, searchWithText: newText as String)
    return true
  }
}

//
//  SearchBar.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/4/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class SearchBar: UIView {
    
    // MARK: - Variables
    
    var textField = SearchTextField(frame: CGRectZero)
    private var imageView = UIImageView(frame: CGRectZero)
    private var magnifyingGlassImage = UIImage(named: "MagnifyingGlass")
    
    var getTextField: UITextField? {
        didSet {
            self.getTextField = self.textField
        }
    }
    
    // MARK: - Constants
    
    private let indent: CGFloat = 10.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 242.0/255, green: 242.0/255, blue: 245.0/255, alpha: 1.0)
        
        // Add magnifying glass
        self.imageView.image = self.magnifyingGlassImage
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.layer.zPosition = 2.0
        
        self.addSubview(self.textField)
        self.addSubview(self.imageView)
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        
        constrain(self.textField, self.imageView) {
            textField, imageView in
            
            imageView.width == 24.0
            imageView.height == 24.0
            imageView.leading == imageView.superview!.leading + indent
            imageView.centerY == imageView.superview!.centerY

            textField.leading == imageView.trailing + indent
            textField.height == 44.0
            textField.centerY == textField.superview!.centerY
            textField.trailing == textField.superview!.trailing - 1
            
        }
    }

}

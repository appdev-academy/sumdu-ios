//
//  BackButton.swift
//  SumDU
//
//  Created by Yura Voevodin on 13.07.16.
//  Copyright © 2016 App Dev Academy. All rights reserved.
//

import UIKit

class BackButton: UIButton {
    
    // MARK: - Constants
    
    static let buttonSize = CGSize(width: 24.0, height: 24.0)
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setImage(UIImage(named: "back_normal"), forState: .Normal)
        setImage(UIImage(named: "back_pressed"), forState: .Selected)
        contentMode = .ScaleAspectFill
        imageEdgeInsets = UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)
        clipsToBounds = true
    }
}
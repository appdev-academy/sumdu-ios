//
//  CustomTableViewCell.swift
//  SumDU
//
//  Created by Oleksandr Kysil on 5/7/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import UIKit
import Cartography

class CustomTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "\(CustomTableViewCell.self)"
    static let cellHeight: CGFloat = 65.0

    // MARK: - UIObjects
    
    private let label = UILabel()
    private let separatorLine = UIView()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Separator
        separatorLine.backgroundColor = lineColor
        contentView.addSubview(separatorLine)
        constrain(separatorLine, contentView) { separatorLine, superview in
            separatorLine.leading == superview.leading
            separatorLine.trailing == superview.trailing
            separatorLine.bottom == superview.bottom
            separatorLine.height == 1.0
        }
        // Text label
        label.textColor = textColorForTableViewCell
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 20.0)
        contentView.addSubview(label)
        constrain(label, separatorLine, contentView) {
            label, separatorLine, superview in
            
            label.top == superview.top
            label.leading == superview.leading + 14.0
            label.trailing == superview.trailing - 14.0
            label.bottom == separatorLine.top
        }
    }
    
    // Show matching pattern
    private func highlightSearchResults(searchString: String, resultString: String) -> NSMutableAttributedString {
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: resultString)
        let pattern = searchString
        let range: NSRange = NSMakeRange(0, resultString.characters.count)
        
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions())
        
        regex?.enumerateMatchesInString(resultString, options: NSMatchingOptions(), range: range) { (textCheckingResult, matchingFlags, stop) -> Void in
            let subRange = textCheckingResult?.range
            attributedString.addAttribute(NSForegroundColorAttributeName, value: textColorForTableViewCell, range: subRange!)
        }
        
        return attributedString
        
    }
    
    func update(withText text: String, search: Bool, searchingText: String?) {
        label.text = text
        if search {
            label.textColor = defaultColorForObjects
            if let searchingText = searchingText {
                label.attributedText = highlightSearchResults(searchingText, resultString: text)
            }
        } else {
            label.textColor = textColorForTableViewCell
        }
    }
}
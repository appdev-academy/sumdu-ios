//
//  ScheduleCell.swift
//  SumDU
//
//  Created by Yura on 26.12.15.
//  Copyright © 2015 AppDecAcademy. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var pairName: UILabel!
    @IBOutlet weak var pairTime: UILabel!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var groupName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

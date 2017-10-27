//
//  GroupCell.swift
//  breakpoint
//
//  Created by Mac on 10/27/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupTitleLabel: UILabel!
    
    @IBOutlet weak var groupDescriptionLabel: UILabel!
    
    @IBOutlet weak var numberCountLabel: UILabel!
    
    
    func configureCell(title: String, description: String, memberCount: Int) {
        self.groupTitleLabel.text = title.lowercased()
        self.groupDescriptionLabel.text = description.lowercased()
        self.numberCountLabel.text = "\(memberCount) members"
    }
}

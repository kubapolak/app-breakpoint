//
//  FeedCell.swift
//  breakpoint
//
//  Created by Mac on 10/24/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    func configureCell(profileImage: UIImage, email: String, content: String, status: String, time: String) {
        self.profileImg.image = profileImage
        self.emailLbl.text = email
        self.contentLabel.text = content
        self.timeLabel.text = time
        if status != "" {
        self.statusLabel.text = "-\(status)"
        } else {
            self.statusLabel.text = ""
        }
    }
}

//
//  GroupFeedCell.swift
//  breakpoint
//
//  Created by Mac on 10/27/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class GroupFeedCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    func configureCell(profileImage: UIImage, email: String, content: String) {
        self.profileImg.image = profileImage
        self.emailLbl.text = email
        self.contentLbl.text = content
    }
}

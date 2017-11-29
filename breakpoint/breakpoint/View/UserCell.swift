//
//  UserCell.swift
//  breakpoint
//
//  Created by Mac on 10/24/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

//user info cell when searching for new group members
class UserCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var checkImage: UIImageView!
    
    func configureCell(profileImage image: UIImage, email: String, isSelected: Bool) {
        self.profileImage.image = image
        self.emailLabel.text = email
        //checking if the user has already been selected when reusing cells
        if isSelected {
            self.checkImage.isHidden = false
        } else {
            self.checkImage.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //adding or removing the checkmark
        if selected {
            if checkImage.isHidden {
                checkImage.isHidden = false
            } else {
                checkImage.isHidden = true
            }
        }
    }
}

//
//  MyPostsCellTableViewCell.swift
//  breakpoint
//
//  Created by Mac on 11/12/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class MyPostsCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    func configureCell(withContent content: String) {
        self.contentLabel.text = content
    }

}

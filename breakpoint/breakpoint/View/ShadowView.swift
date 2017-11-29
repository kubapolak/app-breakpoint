//
//  ShadowView.swift
//  breakpoint
//
//  Created by Mac on 10/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

//custom shadow for AuthVC login buttons box
class ShadowView: UIView {
    
    override func awakeFromNib() {
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 5
        self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        super.awakeFromNib()
    }
}

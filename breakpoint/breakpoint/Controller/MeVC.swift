//
//  MeVC.swift
//  breakpoint
//
//  Created by Mac on 10/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
    }
    
}

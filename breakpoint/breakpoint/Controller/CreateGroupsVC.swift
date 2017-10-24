//
//  CreateGroupsVC.swift
//  breakpoint
//
//  Created by Mac on 10/24/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class CreateGroupsVC: UIViewController {

    @IBOutlet weak var titleTextField: InsetTextField!
    
    @IBOutlet weak var descriptionTextField: InsetTextField!
    
    @IBOutlet weak var emailSearchTextField: InsetTextField!
    
    @IBOutlet weak var groupMemberLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
    }
}

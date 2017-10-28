//
//  updateUserStatusVC.swift
//  breakpoint
//
//  Created by Mac on 10/28/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class UpdateUserStatusVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var statusSwitch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        
        statusSwitch.selectedSegmentIndex = 0
        
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(UpdateUserStatusVC.closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
    }
    
    @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

  
    @IBAction func confirmButtonTapped(_ sender: Any) {
        var updatedStatus = String()
        if statusSwitch.selectedSegmentIndex == 0 {
            updatedStatus = "casual"
        } else if statusSwitch.selectedSegmentIndex == 1 {
            updatedStatus = "nerd"
        }
        DataService.instance.updateUserStatus(userStatus: updatedStatus) { (updated) in
            if updated {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("couldn't update the user's status")
            }
        }
    }
    
}

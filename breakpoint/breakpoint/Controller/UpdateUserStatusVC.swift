//
//  updateUserStatusVC.swift
//  breakpoint
//
//  Created by Mac on 10/28/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class UpdateUserStatusVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var statusSwitch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        
        DataService.instance.getStatus(forUser: (Auth.auth().currentUser?.uid)!) { (userStatus) in
            
            if userStatus == "casual" {
            self.statusSwitch.selectedSegmentIndex = 0
            } else if userStatus == "nerd" {
            self.statusSwitch.selectedSegmentIndex = 1
            } else {
                self.statusSwitch.selectedSegmentIndex = 0
            }
        }
        
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
        AuthService.status = updatedStatus
        DataService.instance.updateUserStatus(updatedStatus) { (updated) in
            if updated {
                NotificationCenter.default.post(name: NOTIF_STATUS_DID_CHANGE, object: nil)
                self.dismiss(animated: true, completion: nil)
            } else {
                print("couldn't update the user's status")
            }
        }
    }
}

//
//  MeVC.swift
//  breakpoint
//
//  Created by Mac on 10/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailLbl.text = Auth.auth().currentUser?.email
        setupStatusLabel()
        
    }
    
    func setupStatusLabel() {
        DataService.instance.getUserStatus(forUser: Auth.auth().currentUser!) { (userStatus) in
            self.statusLabel.text = userStatus
        }
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "logout?", message: "are you sure?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "logout", style: .destructive) { (buttonTapped) in
            do {
               try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        logoutPopup.addAction(logoutAction)
        present(logoutPopup, animated: true, completion: nil)
    }
    
    @IBAction func setStatusButtonPressed(_ sender: Any) {
        let updateUserStatusVC = UpdateUserStatusVC()
        present(updateUserStatusVC, animated: true, completion: nil)
    }
    
}

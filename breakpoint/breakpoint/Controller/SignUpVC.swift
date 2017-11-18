//
//  SignUpVC.swift
//  breakpoint
//
//  Created by Mac on 11/18/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {

    @IBOutlet weak var emailField: InsetTextField!
    
    @IBOutlet weak var passwordField: InsetTextField!
    
    @IBOutlet weak var passwordRepeatField: InsetTextField!
    
    @IBOutlet weak var emailTakenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fadeOutLabel() {
        UIView.animate(withDuration: 2, animations: {
            self.emailTakenLabel.isHidden = false
            self.emailTakenLabel.alpha = 0
        }) { (finished) in
            if finished {
                self.emailTakenLabel.isHidden = true
                self.emailTakenLabel.alpha = 1
            }
        }
    }
    
    func register() {
//        AuthService.instance.registerUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, userCreationComplete: { (success, registrationError) in
            //                    if success {
            //                        AuthService.instance.loginUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, loginComplete: { (success, nil) in
            //                            NotificationCenter.default.post(name: NOTIF_STATUS_DID_CHANGE, object: nil)
            //                            self.dismiss(animated: true, completion: nil)
            //                            print("successfully registered user")
            //                        })
            //                    } else {
            //                        print(String(describing: registrationError?.localizedDescription))
            //                    }
            //                })
    }
    
    
    @IBAction func signupButtonPressed(_ sender: Any) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

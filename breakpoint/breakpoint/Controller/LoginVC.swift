//
//  LoginVC.swift
//  breakpoint
//
//  Created by Mac on 10/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    
    @IBOutlet weak var emailField: InsetTextField!
    
    @IBOutlet weak var passwordField: InsetTextField!
    
    @IBOutlet weak var wrongCredLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func fadeOutLabel() {
        UIView.animate(withDuration: 2, animations: {
            self.wrongCredLabel.isHidden = false
            self.wrongCredLabel.alpha = 0
        }) { (finished) in
            if finished {
                self.wrongCredLabel.isHidden = true
                self.wrongCredLabel.alpha = 1
            }
        }
    }

    @IBAction func signInButtonPressed(_ sender: Any) {
        

        if emailField.text != nil && passwordField.text != nil {
            AuthService.instance.loginUser(withEmail: emailField.text!, andPassword: passwordField.text!, loginComplete: { (success, loginError) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(String(describing: loginError?.localizedDescription))
                    self.fadeOutLabel()
                }
            })
        } else {
            
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LoginVC: UITextFieldDelegate { }

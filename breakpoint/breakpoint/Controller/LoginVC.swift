//
//  LoginVC.swift
//  breakpoint
//
//  Created by Mac on 10/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

//Logging in with email as a Firebase User
class LoginVC: UIViewController {

    
    @IBOutlet weak var emailField: InsetTextField!
    
    @IBOutlet weak var passwordField: InsetTextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    //error label animation
    func presentFadeOutLabel(withText text: String) {
        signInButton.isEnabled = false
        errorLabel.text = text
        UIView.animate(withDuration: 2, animations: {
            self.errorLabel.isHidden = false
            self.errorLabel.alpha = 0
        }) { (finished) in
            if finished {
                self.errorLabel.isHidden = true
                self.errorLabel.alpha = 1
                self.signInButton.isEnabled = true
            }
        }
    }

    @IBAction func signInButtonPressed(_ sender: Any) {
        if emailField.text != "" && passwordField.text != "" {
            AuthService.instance.loginUser(withEmail: emailField.text!, andPassword: passwordField.text!, loginComplete: { (success, loginError) in
                if success {
                    AuthService.instance.setupUserUI()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(String(describing: loginError?.localizedDescription))
                    self.presentFadeOutLabel(withText: (loginError?.localizedDescription)!)
                }
            })
        } else {
            presentFadeOutLabel(withText: "fill out all the info")
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LoginVC: UITextFieldDelegate { }

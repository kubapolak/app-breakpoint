//
//  SignUpVC.swift
//  breakpoint
//
//  Created by Mac on 11/18/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

//Signing up as a Firebase User
class SignUpVC: UIViewController {

    @IBOutlet weak var emailField: InsetTextField!
    
    @IBOutlet weak var passwordField: InsetTextField!
    
    @IBOutlet weak var passwordRepeatField: InsetTextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fadeOutLabel(withText text: String) {
        signUpButton.isEnabled = false
        errorLabel.text = text
        UIView.animate(withDuration: 2, animations: {
            self.errorLabel.isHidden = false
            self.errorLabel.alpha = 0
        }) { (finished) in
            if finished {
                self.errorLabel.isHidden = true
                self.errorLabel.alpha = 1
                self.signUpButton.isEnabled = true
            }
        }
    }
    
    func register() {
        AuthService.instance.registerUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, userCreationComplete: { (success, registrationError) in
                                if success {
                                    AuthService.instance.loginUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, loginComplete: { (success, nil) in
                                        AuthService.instance.setupUserUI()
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                } else {
                                    print(String(describing: registrationError?.localizedDescription))
                                    self.fadeOutLabel(withText: (registrationError?.localizedDescription)!)
                                }
                            })
    }
    
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        if emailField.text != "" && passwordField.text != "" && passwordRepeatField.text != "" {
            if passwordField.text == passwordRepeatField.text {
                register()
            } else {
                fadeOutLabel(withText: "passwords must match")
            }
        } else {
            fadeOutLabel(withText: "fill out all required info")
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//
//  AuthVC.swift
//  breakpoint
//
//  Created by Mac on 10/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class AuthVC: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func facebookSignInButtonPressed(_ sender: Any) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil {
                print("FB login failed: \(error?.localizedDescription)")
                return
            }
            print(result?.token.tokenString)
        }
    }
    
    @IBAction func googleSignInButtonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signInWithEmailButtonPressed(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        present(loginVC!, animated: true, completion: nil)
    }
    
    
    @IBAction func signUpLocalPressed(_ sender: Any) {
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpVC")
        present(signUpVC!, animated: true, completion: nil)
    }
    
}

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

//Initial authentication/login view
class AuthVC: UIViewController, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(AuthVC.userDidLogin(_:)), name: NOTIF_USER_DID_LOGIN, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //dismisses the view after firebase login/registration
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //dismisses the view after facebook/google login
    @objc func userDidLogin(_ notif: Notification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func facebookSignInButtonPressed(_ sender: Any) {
        AuthService.instance.loginUserWithFB()
    }
    
    @IBAction func googleSignInButtonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
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

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

class AuthVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginFBButton: FBSDKLoginButton!
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self as GIDSignInDelegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("error: \(error.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            } else {
                print("user signed in")
                let id = user?.uid
                let username = user?.email!
                DataService.instance.addThirdPartyUserInfo(id: id!, username: username!, provider: "Google")
                AuthService.instance.setupUserUI()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("error: \(error.localizedDescription)")
            return
        }
        print("DISCONNECTED")
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
//            if error != nil {
//                print("FB login failed: \(error?.localizedDescription)")
//                return
//            } else {
//        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
//            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString!)
//            Auth.auth().signIn(with: credential) { (user, error) in
//                if let error = error {
//                    print("error: \(error)")
//                    return
//                }
//                print("user signed in with FB!")
//                DataService.instance.addThirdPartyUserInfo(id: (user?.uid)!, username: (user?.email)!, provider: "Facebook")
//                AuthService.instance.setupUserUI()
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//        }
    }
    
    @IBAction func facebookSignInButtonPressed(_ sender: Any) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil {
                print("FB LOGIN FAILED!")
                return
            }
            print(result?.token.tokenString)
        }
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

//
//  AuthService.swift
//  breakpoint
//
//  Created by Mac on 10/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import Firebase

class AuthService {
    static let instance = AuthService()
    
    static var avatar = UIImage(named: "defaultProfileImage")
    static var status = String()
    
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let user = user else {
                userCreationComplete(false, error)
                return
            }
            
            let userData = ["provider": user.providerID, "email": user.email]
            DataService.instance.createDBUser(uid: user.uid, userData: userData)
            userCreationComplete(true, nil)
        }
    }
    
        func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    loginComplete(false, error)
                    return
                }
                loginComplete(true, nil)
                self.setupUserUI()
        }
    }
    
    func setupUserUI() {
    DataService.instance.downloadUserAvatar(userID: (Auth.auth().currentUser?.uid)!) { (userAvatar) in
    AuthService.avatar = userAvatar
        }
    DataService.instance.getUserStatus(forUser: (Auth.auth().currentUser?.uid)!) { (userStatus) in
    AuthService.status = userStatus
        }
    }
}

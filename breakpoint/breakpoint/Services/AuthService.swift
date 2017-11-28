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
    
    //register user with Firebase
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
    
    //login user with Firebase
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
    
    //get user avatar and status to be accessed across the app
    func setupUserUI() {
        DispatchQueue.global(qos: .userInitiated).async {
            DataService.instance.downloadUserAvatar(userID: (Auth.auth().currentUser?.uid)!) { (userAvatar, finished) in
                if finished {
                    AuthService.avatar = userAvatar
                    NotificationCenter.default.post(name: NOTIF_AVATAR_DID_CHANGE, object: nil)
                }
            }
            DataService.instance.getStatus(forUser: (Auth.auth().currentUser?.uid)!) { (userStatus) in
                AuthService.status = userStatus
                NotificationCenter.default.post(name: NOTIF_STATUS_DID_CHANGE, object: nil)
            }
        }
    }
}

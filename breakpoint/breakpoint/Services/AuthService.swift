//
//  AuthService.swift
//  breakpoint
//
//  Created by Mac on 10/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit

//Authentication Manager (google-based login set up in AppDelegate.swift)
class AuthService {
    static let instance = AuthService()
    
    //User's info accessed across the app
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
    
    //login user with FB
    func loginUserWithFB() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"]) { (result, error) in
            if error != nil {
                print("fb login failed: \(error!.localizedDescription)")
                return
            } else if (result?.isCancelled)! {
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString!)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("error, couldnt sign in with firebase: \(error.localizedDescription)")
                    return
                }
                DataService.instance.addThirdPartyUserInfo(id: (user?.uid)!, username: (user?.email)!, provider: "Facebook")
                AuthService.instance.setupUserUI()
                NotificationCenter.default.post(name: NOTIF_USER_DID_LOGIN, object: nil)
            })
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

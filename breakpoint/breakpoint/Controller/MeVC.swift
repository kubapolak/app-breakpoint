//
//  MeVC.swift
//  breakpoint
//
//  Created by Mac on 10/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var setStatusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(MeVC.userStatusDidChange(_:)), name: NOTIF_STATUS_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MeVC.userAvatarDidChange(_:)), name: NOTIF_AVATAR_DID_CHANGE, object: nil)
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailLbl.text = Auth.auth().currentUser?.email
        setupView()
    }
    
    @objc func userStatusDidChange(_ notif: Notification) {
        setupView()
    }
    
    @objc func userAvatarDidChange(_ notif: Notification) {
        setupView()
    }
    
    func setupView() {
        statusLabel.text = AuthService.status
        profileImage.image = AuthService.avatar
        setupButtonText()
    }
    
    func setupButtonText() {
        if self.statusLabel.text == "" {
            setStatusButton.setTitle("set status", for: .normal)
        } else {
            setStatusButton.setTitle("change status", for: .normal)
        }
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "logout?", message: "are you sure?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "logout", style: .destructive) { (buttonTapped) in
            do {
               try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(logoutPopup, animated: true, completion: nil)
        AuthService.avatar = UIImage(named: "defaultProfileImage")
        AuthService.status = String()
    }
    
    @IBAction func setStatusButtonPressed(_ sender: Any) {
        let updateUserStatusVC = UpdateUserStatusVC()
        updateUserStatusVC.modalPresentationStyle = .custom
        present(updateUserStatusVC, animated: true, completion: nil)
    }
    
    @IBAction func photoButtonPressed(_ sender: Any) {
        let addPhotoVC = AddPhotoVC()
        addPhotoVC.modalPresentationStyle = .custom
        present(addPhotoVC, animated: true, completion: nil)
    }
    
}

extension MeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myPostCell") as? MyPostsCell else { return UITableViewCell() }
        cell.configureCell(withContent: "LOL")
        return cell
    }
}

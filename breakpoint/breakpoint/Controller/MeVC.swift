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
    
    @IBOutlet weak var myMsgsToggle: UISegmentedControl!
    
    var myGroups = [Group]()
    var myFeedMessages = [String]()
    var myGroupTitles = [String]()
    var myGroupMessages = [[String]]()
    
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
        clearArrays()
        setupView()
        getMyMessages()
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
    
    func getMyMessages() {
        if myMsgsToggle.selectedSegmentIndex == 0 {
            getMyFeedMessages()
            tableView.reloadData()
        } else if myMsgsToggle.selectedSegmentIndex == 1 {
            getMyGroupMessages()
            tableView.reloadData()
        }
    }
    
    func clearArrays() {
        myFeedMessages = []
        myGroups = []
        myGroupTitles = []
        myGroupMessages = []
        tableView.reloadData()
    }
    
    func getMyFeedMessages() {
        DataService.instance.getMyFeedMessages { (returnedMessages) in
            self.myFeedMessages = returnedMessages
            self.tableView.reloadData()
        }
    }
    
    func getMyGroupMessages() {
        DataService.instance.getAllGroups { (returnedGroups) in
            self.myGroups = returnedGroups
            DataService.instance.getMyGroupMessages(self.myGroups, handler: { (returnedGroupMessages, returnedTitles, finished) in
                if finished {
                    self.myGroupMessages = returnedGroupMessages
                    self.myGroupTitles = returnedTitles
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func setupButtonText() {
        if self.statusLabel.text == "" {
            setStatusButton.setTitle("set status", for: .normal)
        } else {
            setStatusButton.setTitle("change status", for: .normal)
        }
    }
    
    @IBAction func myMsgsToggleTapped(_ sender: UISegmentedControl) {
        getMyMessages()
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
        var numOfSections = 0
        if myMsgsToggle.selectedSegmentIndex == 0 {
            numOfSections = 1
        } else if myMsgsToggle.selectedSegmentIndex == 1 {
            numOfSections = myGroupMessages.count
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as?UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = #colorLiteral(red: 0.8133803456, green: 1, blue: 0.9995977238, alpha: 1)
            headerTitle.backgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionHeader = ""
        if myMsgsToggle.selectedSegmentIndex == 1 {
            sectionHeader = myGroupTitles[section]
        }
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows = 0
        if myMsgsToggle.selectedSegmentIndex == 0 {
            numOfRows = myFeedMessages.count
        } else if myMsgsToggle.selectedSegmentIndex == 1 {
            numOfRows = myGroupMessages[section].count
        }
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myPostCell") as? MyPostsCell else { return UITableViewCell() }
        var content = ""
        if myMsgsToggle.selectedSegmentIndex == 0 {
            content = myFeedMessages[indexPath.row]
        } else if myMsgsToggle.selectedSegmentIndex == 1 {
            content = myGroupMessages[indexPath.section][indexPath.row]
        }
        cell.configureCell(withContent: content)
        return cell
    }
}

//
//  MeVC.swift
//  breakpoint
//
//  Created by Mac on 10/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

//User's profile overview/manager
class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var setStatusButton: UIButton!
    
    @IBOutlet weak var myMsgsToggle: UISegmentedControl!
    
    var myFeedMessages = [String]()
    var myGroups = [Group]()
    var myGroupTitles = [String]()
    var myGroupMessages = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupView()
        getMyMessages()
    }
    
    func addObservers() {
        //for when the user changes the status or the avatar
        NotificationCenter.default.addObserver(self, selector: #selector(MeVC.userStatusDidChange(_:)), name: NOTIF_STATUS_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MeVC.userAvatarDidChange(_:)), name: NOTIF_AVATAR_DID_CHANGE, object: nil)
    }
    
    @objc func userStatusDidChange(_ notif: Notification) {
        statusLabel.text = AuthService.status
        setupButtonText()
    }
    
    @objc func userAvatarDidChange(_ notif: Notification) {
        profileImage.image = AuthService.avatar
    }
    
    func setupView() {
        emailLbl.text = Auth.auth().currentUser?.email
        statusLabel.text = AuthService.status
        profileImage.image = AuthService.avatar
        setupButtonText()
    }
    
    //status button text changed based on whether the status has been set
    func setupButtonText() {
        if self.statusLabel.text == "" {
            setStatusButton.setTitle("set status", for: .normal)
        } else {
            setStatusButton.setTitle("change status", for: .normal)
        }
    }
    
    //clears everything when logging out
    func clearUserInfo() {
        myFeedMessages = []
        myGroups = []
        myGroupTitles = []
        myGroupMessages = []
        tableView.reloadData()
        emailLbl.text = ""
        statusLabel.text = ""
        profileImage.image = UIImage(named: "defaultProfileImage")
    }
    
    //downloads user's messages from the Main Feed or from the Group Feeds
    func getMyMessages() {
        if myMsgsToggle.selectedSegmentIndex == 0 {
            getMyFeedMessages()
        } else if myMsgsToggle.selectedSegmentIndex == 1 {
            getMyGroupMessages()
        }
    }
    
    func getMyFeedMessages() {
        DispatchQueue.global(qos: .utility).async {
            DataService.instance.getMyFeedMessages { (returnedMessages) in
                self.myFeedMessages = returnedMessages
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getMyGroupMessages() {
        DispatchQueue.global(qos: .utility).async {
            DataService.instance.getAllGroups { (returnedGroups) in
                self.myGroups = returnedGroups
                DataService.instance.getMyGroupMessages(self.myGroups, handler: { (returnedGroupMessages, returnedTitles, finished) in
                    if finished {
                        self.myGroupMessages = returnedGroupMessages
                        self.myGroupTitles = returnedTitles
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
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
                self.clearUserInfo()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(logoutPopup, animated: true, completion: nil)
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
    
    //header style when displaying group sections
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

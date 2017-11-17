//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Mac on 10/27/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class GroupFeedVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var sendButtonView: UIView!
    @IBOutlet weak var messageTextField: InsetTextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var noMessagesLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    var group: Group?
    var groupMessages = [Message]()
    var groupAvatars = [String: UIImage]()
    var avatarsDownloaded = Bool()
    
    func initData(forGroup group: Group) {
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButtonView.bindToKeyboard()
        tableView.delegate = self
        tableView.dataSource = self
        avatarsDownloaded = false
        getUserAvatars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLabel.text = group?.groupTitle
        DataService.instance.getEmailsForGroup(group: group!) { (returnedEmails) in
            self.membersLabel.text = returnedEmails.joined(separator: ", ")
        }
        getMessages()
    }
    
    func getMessages() {
        noMessagesLabel.isHidden = true
        spinner.isHidden = false
        spinner.startAnimating()
        loadingLabel.isHidden = false
        DataService.instance.REF_GROUPS.observe(.value) { (snapShot) in
            DataService.instance.getAllMessagesFor(desiredGroup: self.group!, handler: { (returnedGroupMessages) in
                self.groupMessages = returnedGroupMessages
                if self.avatarsDownloaded {
                    self.spinner.stopAnimating()
                    self.spinner.isHidden = true
                    self.loadingLabel.isHidden = true
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            })
        }
    }
    
    func scrollToBottom() {
        if self.groupMessages.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.groupMessages.count - 1, section: 0), at: .bottom, animated: true)
        } else {
            self.noMessagesLabel.isHidden = false
        }
    }
    
    func getUserAvatars() {
        spinner.isHidden = false
        spinner.startAnimating()
        loadingLabel.isHidden = false
        DataService.instance.getAvatarsForGroup(group: group!) { (returnedDict, finished) in
            if finished {
                self.groupAvatars = returnedDict
                self.avatarsDownloaded = true
                self.getMessages()
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismissDetail()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if messageTextField.text != "" {
            noMessagesLabel.isHidden = true
            messageTextField.isEnabled = false
            sendButton.isEnabled = false
            DataService.instance.uploadPost(withMessage: messageTextField.text!, forUID: Auth.auth().currentUser!.uid, withGroupKey: group?.key, sendComplete: { (complete) in
                if complete {
                    self.messageTextField.text = ""
                    self.messageTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                }
            })
        }
    }
    
}

extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell", for: indexPath) as? GroupFeedCell else { return UITableViewCell() }
        let message = groupMessages[indexPath.row]
        DataService.instance.getUsername(forUID: message.senderId) { (email) in
            let emailStr = email.components(separatedBy: "@")
            let userName = emailStr[0]
            cell.configureCell(profileImage: self.groupAvatars["\(message.senderId)"]!, email: userName, content: message.content)
        }
        return cell
    }
}

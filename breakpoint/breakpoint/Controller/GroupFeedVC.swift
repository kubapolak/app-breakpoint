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
        
        DataService.instance.REF_GROUPS.observe(.value) { (snapShot) in
            DataService.instance.getAllMessagesFor(desiredGroup: self.group!, handler: { (returnedGroupMessages) in
                self.groupMessages = returnedGroupMessages
                if self.avatarsDownloaded {
                    self.tableView.reloadData()
                    if self.groupMessages.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath.init(row: self.groupMessages.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            })
        }
    }
    
    func getUserAvatars() {
        DataService.instance.getAvatarsForGroup(group: group!) { (returnedDict, finished) in
            if finished {
                self.avatarsDownloaded = true
                self.groupAvatars = returnedDict
                self.tableView.reloadData()
                if self.groupMessages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath.init(row: self.groupMessages.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismissDetail()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if messageTextField.text != "" {
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
            cell.configureCell(profileImage: self.groupAvatars["\(message.senderId)"]!, email: email, content: message.content)
        }
        return cell
    }
}

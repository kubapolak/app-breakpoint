//
//  FirstViewController.swift
//  breakpoint
//
//  Created by Mac on 10/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messageArray = [Message]()
    var usernameArray = [String]()
    var avatarArray = [UIImage]()
    var idArray = [String]()
    var statusArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if Auth.auth().currentUser != nil {
        AuthService.instance.setupUserUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clearArrays()
        getMessages()
        
        if self.messageArray.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func clearArrays() {
        messageArray = []
        usernameArray = []
        avatarArray = []
        idArray = []
        statusArray = []
        tableView.reloadData()
    }
    
    func getUsersData(handler: @escaping (_ done: Bool) -> ()) {
        for message in self.messageArray {
            self.idArray.append(message.senderId)
            DataService.instance.getUserStatus(forUser: message.senderId, handler: { (status) in
                self.statusArray.append(status)
                print("STATUSES, \(self.statusArray.count)")
            })
            DataService.instance.getUsername(forUID: message.senderId, handler: { (username) in
                self.usernameArray.append(username)
                print("EMAILS, \(self.usernameArray.count)")
                if self.usernameArray.count == self.messageArray.count {
                    print("LOL?")
                    handler(true)
                }
            })
        }
    }
    
    func getMessages() {
        DataService.instance.getAllFeedMessages { (returnedMessagesArray, finished) in
            self.messageArray = returnedMessagesArray.reversed()
            if finished {
            print("MESSAGES, \(self.messageArray.count)")
                self.getUsersData(handler: { (finished) in
                    if finished {
                        print("GOT USER DATA")
                    DataService.instance.downloadMultipleAvatars(ids: self.idArray, handler: { (avatars, finished) in
                        self.avatarArray = avatars
                        if finished {
                            print("AVATARS")
                            self.tableView.reloadData()
                        }
                    })
                    }
                })
            }
        }
    }
}

extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as? FeedCell else { return UITableViewCell() }
        let content = messageArray[indexPath.row].content
        let image = avatarArray[indexPath.row]
        let email = usernameArray[indexPath.row]
        let status = statusArray[indexPath.row]
        cell.configureCell(profileImage: image, email: email, content: content, status: status)
//        DataService.instance.getUsername(forUID: message.senderId) { (returnedUsername) in
//            DataService.instance.getUserStatus(forUser: message.senderId, handler: { (userStatus) in
//                DataService.instance.downloadUserAvatar(userID: message.senderId) { (avatar) in
//                    image = avatar
//            cell.configureCell(profileImage: image!, email: returnedUsername, content: message.content, status: userStatus)
//                }
//                })
//            }
        
        return cell
    }
}

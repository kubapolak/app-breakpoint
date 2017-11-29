//
//  FirstViewController.swift
//  breakpoint
//
//  Created by Mac on 10/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

//Main Feed
class FeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noMessagesLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var actSpinner: UIActivityIndicatorView!
    
    private let refreshControl = UIRefreshControl()
    
    var messageArray = [Message]()
    var usernameDict = [String: String]()
    var idArray = [String]()
    var tempIdArray = [String]()
    var feedAvatars = [String: UIImage]()
    var statusDict = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addPullToRefresh()
        addObservers()
        
        if Auth.auth().currentUser != nil {
            AuthService.instance.setupUserUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getMessages()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.userStatusDidChange(_:)), name: NOTIF_STATUS_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.userAvatarDidChange(_:)), name: NOTIF_AVATAR_DID_CHANGE, object: nil)
    }
    
    @objc func userStatusDidChange(_ notif: Notification) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        if idArray.contains(id) {
            DataService.instance.getStatus(forUser: id) { (status) in
                self.statusDict[id] = status
            }
        }
    }
    
    @objc func userAvatarDidChange(_ notif: Notification) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        if idArray.contains(id) {
            DataService.instance.downloadUserAvatar(userID: id) { (avatar, finished) in
                if finished {
                    self.feedAvatars[id] = avatar
                }
            }
        }
    }
    
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.8133803456, green: 1, blue: 0.9995977238, alpha: 1)
    }
    
    @objc private func refresh(_ sender: Any) {
        loadingLabel.isHidden = false
        getMessages()
    }
    
    func clearUserData() {
        messageArray = []
        usernameDict = [:]
        idArray = []
        feedAvatars = [:]
        statusDict = [:]
    }
    
    func getUserIds(handler: @escaping (_ done: Bool) -> ()) {
        tempIdArray = []
        for message in self.messageArray {
            let id = message.senderId
            if !self.idArray.contains(id) {
                self.idArray.append(id)
                self.tempIdArray.append(id)
            }
        }
        handler(true)
    }
    
    func getUserData(handler: @escaping (_ done: Bool) -> ()) {
        for id in tempIdArray {
            DataService.instance.getStatus(forUser: id, handler: { (status) in
                self.statusDict["\(id)"] = status
            })
            DataService.instance.getUsername(forUID: id, handler: { (username) in
                self.usernameDict["\(id)"] = username
                if self.usernameDict.count == self.idArray.count {
                    handler(true)
                }
            })
        }
    }
    
    func getMessages() {
        noMessagesLabel.isHidden = true
        actSpinner.isHidden = false
        actSpinner.startAnimating()
        loadingLabel.isHidden = false
        DispatchQueue.global(qos: .utility).async {
        DataService.instance.getAllFeedMessages { (returnedMessagesArray, finished) in
            if returnedMessagesArray.count > 0 {
            self.messageArray = returnedMessagesArray.reversed()
            if finished {
                self.getUserIds(handler: { (finished) in
                    if finished {
                        if self.idArray.count == self.usernameDict.count {
                            self.actSpinner.stopAnimating()
                            self.actSpinner.isHidden = true
                            self.loadingLabel.isHidden = true
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.tableView.refreshControl?.endRefreshing()
                            }
                        } else {
                            self.getUserData(handler: { (finished) in
                                if finished {
                                self.actSpinner.stopAnimating()
                                self.actSpinner.isHidden = true
                                self.loadingLabel.isHidden = true
                                DispatchQueue.main.async {
                                    self.tempIdArray = self.idArray
                                    self.tableView.reloadData()
                                }
                                }
                            })
                        }
                    }
                })
                }
            } else {
                self.actSpinner.stopAnimating()
                self.actSpinner.isHidden = true
                self.loadingLabel.isHidden = true
                self.noMessagesLabel.isHidden = false
                return
            }
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
        
        let message = messageArray[indexPath.row]
        let content = message.content
        let time = message.time
        let tempImage = UIImage(named: "defaultProfileImage")
        let id = message.senderId
        let email = usernameDict[id]
        let status = statusDict[id]
        
        cell.configureCell(profileImage: tempImage!, email: email!, content: content, status: status!, time: time)
        
        if let cacheAvatar = feedAvatars[id] {
            cell.profileImg.image = cacheAvatar
        } else {
            DispatchQueue.global(qos: .background).async {
                DataService.instance.downloadUserAvatar(userID: id, handler: { (avatar, finished) in
                    if finished {
                        self.feedAvatars[id] = avatar
                        DispatchQueue.main.async {
                            cell.profileImg.image = avatar
                        }
                    }
                })
            }
        }
        return cell
    }
}

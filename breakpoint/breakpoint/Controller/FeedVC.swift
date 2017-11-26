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
    
    @IBOutlet weak var noMessagesLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var actSpinner: UIActivityIndicatorView!
    
    private let refreshControl = UIRefreshControl()
    
    var messageArray = [Message]()
    var usernameDict = [String: String]()
    var idArray = [String]()
    var feedAvatars = [String: UIImage]()
    var statusDict = [String: String]()
    var avatarsDownloaded = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.userStatusDidChange(_:)), name: NOTIF_STATUS_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.userAvatarDidChange(_:)), name: NOTIF_AVATAR_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.userDidJustLogin(_:)), name: NOTIF_USER_DID_LOGIN, object: nil)
        
        addPullToRefresh()
        if Auth.auth().currentUser != nil {
            AuthService.instance.setupUserUI()
        }
        
        avatarsDownloaded = false
        getMessages()
        scrollToTop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if avatarsDownloaded {
            updateMessages()
            scrollToTop()
        }
    }
    
    @objc func userStatusDidChange(_ notif: Notification) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        if idArray.contains(id) {
            DataService.instance.getUserStatus(forUser: id) { (status) in
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
    
    @objc func userDidJustLogin(_ notif: Notification) {
        print("user just logged in!")
        clearUserData()
        AuthService.instance.setupUserUI()
        getMessages()
        scrollToTop()
    }
    
    func addPullToRefresh() {
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.8133803456, green: 1, blue: 0.9995977238, alpha: 1)
    }

    func scrollToTop() {
        if self.messageArray.count > 0 {
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    @objc private func refresh(_ sender: Any) {
        loadingLabel.isHidden = false
        updateMessages()
        scrollToTop()
    }
    
    func clearUserData() {
        messageArray = []
        usernameDict = [:]
        idArray = []
        feedAvatars = [:]
        statusDict = [:]
        avatarsDownloaded = false
    }
    
    func getUserIds(handler: @escaping (_ done: Bool) -> ()) {
        for message in self.messageArray {
            self.idArray.append(message.senderId)
        }
        self.idArray = Array(Set(self.idArray))
        handler(true)
    }
    
    func getUserData(handler: @escaping (_ done: Bool) -> ()) {
        for id in idArray {
        DataService.instance.getUserStatus(forUser: id, handler: { (status) in
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
                        self.getUserData(handler: { (finished) in
                            self.actSpinner.stopAnimating()
                            self.actSpinner.isHidden = true
                            self.loadingLabel.isHidden = true
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }

                        })
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
    
    func updateMessages()  {
        loadingLabel.text = "updating..."
        noMessagesLabel.isHidden = true
        actSpinner.isHidden = false
        actSpinner.startAnimating()
        loadingLabel.isHidden = false
        var allUsersConfigured = false
        
        DispatchQueue.global(qos: .utility).async {
        DataService.instance.getAllFeedMessages { (returnedMessagesArray, finished) in
            if returnedMessagesArray.count > 0 {
                self.messageArray = returnedMessagesArray.reversed()
                if finished {
                    self.getUserIds { (finished) in
                        if finished {
                            var tempIds = self.idArray
                            for savedId in self.feedAvatars.keys {
                                if self.idArray.contains(savedId) {
                                    let index = tempIds.index(of: savedId)
                                    tempIds.remove(at: index!)
                                }
                            }
                            if tempIds.count == 0 {
                                allUsersConfigured = true
                            } else {
                                allUsersConfigured = false
                            }
                            if allUsersConfigured && self.idArray.count == self.feedAvatars.count {
                                self.actSpinner.stopAnimating()
                                self.actSpinner.isHidden = true
                                self.loadingLabel.isHidden = true
                                
                                self.refreshControl.endRefreshing()
                                
                                self.tableView.reloadData()
                            } else {
                                self.getUserData(handler: { (finished) in
                                })
                                for id in tempIds {
                                    DataService.instance.downloadUserAvatar(userID: id, handler: { (avatar, done) in
                                        if done {
                                            self.feedAvatars[id] = avatar
                                            if self.feedAvatars.count == self.idArray.count {
                                                self.avatarsDownloaded = true
                                                self.actSpinner.stopAnimating()
                                                self.actSpinner.isHidden = true
                                                self.loadingLabel.isHidden = true
                                                DispatchQueue.main.async {
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                    
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
        DispatchQueue.global(qos: .utility).async {
            DataService.instance.downloadUserAvatar(userID: id, handler: { (avatar, finished) in
                if finished {
                    self.feedAvatars[id] = avatar
                    DispatchQueue.main.async {
                        cell.profileImg.image = avatar
                    }
                    if self.feedAvatars.count == self.idArray.count {
                        self.avatarsDownloaded = true
                        print("all \(self.feedAvatars.count) avatars downloaded")
                    }
                }
            })
        }
        }
        return cell
    }
}

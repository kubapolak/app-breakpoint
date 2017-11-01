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
        DataService.instance.getAllFeedMessages { (returnedMessagesArray) in
            self.messageArray = returnedMessagesArray.reversed()
            self.tableView.reloadData()
            
            if self.messageArray.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
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
        var image = UIImage(named: "defaultProfileImage")
        let message = messageArray[indexPath.row]
        
        
        
   
        
        DataService.instance.getUsername(forUID: message.senderId) { (returnedUsername) in
            DataService.instance.getUserStatus(forUser: message.senderId, handler: { (userStatus) in
                DataService.instance.downloadUserAvatar(userID: message.senderId) { (avatar) in
                    image = avatar
            cell.configureCell(profileImage: image!, email: returnedUsername, content: message.content, status: userStatus)
                }
                })
            }
        return cell
    }
}

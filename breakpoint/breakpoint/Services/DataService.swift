//
//  DataService.swift
//  breakpoint
//
//  Created by Mac on 10/15/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

//Handling Database
class DataService {
    static let instance = DataService()
    
    //Database references
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    var REF_FEED: DatabaseReference {
        return _REF_FEED
    }
    
    
    //FUNCTIONS
    
    
    //CURRENT USER
    
    //add user info to database
    func createDBUser(uid: String, userData: Dictionary<String,Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    //adds Facebook/Google user info to Firebase DB, simplifies getting user info/avatar
    func addThirdPartyUserInfo(id: String, username: String, provider: String) {
        REF_USERS.child(id).updateChildValues(["email": username, "provider": provider])
    }
    
    //adding or changing user's status
    func updateUserStatus(_ status: String, handler: @escaping (_ statusUpdated: Bool) -> ()) {
        REF_USERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["status": status])
        handler(true)
    }
    
    //getting user's own messages from the Main Feed to be displayed in MeVC
    func getMyFeedMessages(handler: @escaping (_ messagesArray: [String]) -> ()) {
        var messagesArray = [String]()
        REF_FEED.observeSingleEvent(of: .value) { (feedSnapshot) in
            guard let feedSnapshot = feedSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for message in feedSnapshot {
                let id = message.childSnapshot(forPath: "senderId").value as! String
                if id == Auth.auth().currentUser?.uid {
                    let content = message.childSnapshot(forPath: "content").value as! String
                    messagesArray.append(content)
                }
            }
            handler(messagesArray.reversed())
        }
    }
    
    //getting user's own messages from all groups to be displayed in MeVC
    func getMyGroupMessages(_ groups: [Group], handler: @escaping (_ messageGroupsArray: [[String]], _ groupTitles: [String], _ done: Bool) -> ()) {
        var messageGroupsArray = [[String]]()
        var groupTitles = [String]()
        for group in groups {
            let title = group.groupTitle
            groupTitles.append(title)
            var messagesArray = [String]()
            REF_GROUPS.child(group.key).child("messages").observeSingleEvent(of: .value) { (groupMessageSnapshot) in
                guard let groupMessageSnapshot = groupMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for groupMessage in groupMessageSnapshot {
                    let content = groupMessage.childSnapshot(forPath: "content").value as! String
                    let senderId = groupMessage.childSnapshot(forPath: "senderId").value as! String
                    if senderId == Auth.auth().currentUser?.uid {
                        messagesArray.append(content)
                    }
                }
                messageGroupsArray.append(messagesArray.reversed())
                if messageGroupsArray.count == groups.count {
                    handler(messageGroupsArray, groupTitles, true)
                }
            }
        }
    }
    
    
    //OTHER USERS
    
    //getting an email based on ID
    func getUsername(forUID uid: String, handler: @escaping (_ username: String) -> ()) {
        REF_USERS.child(uid).child("email").observeSingleEvent(of: .value, with: { (snap) in
            guard let email = snap.value as? String else { return }
            handler(email)
        })
    }
    
    //getting the status of a user
    func getStatus(forUser userUid: String, handler: @escaping (_ userStatus: String) -> ()) {
        REF_USERS.child(userUid).child("status").observeSingleEvent(of: .value, with: { (snap) in
            if let status = snap.value as? String {
                handler(status)
            } else {
                handler("")
            }
        })
    }
    
    //getting the avatar of a user
    func downloadUserAvatar(userID: String, handler: @escaping (_ image: UIImage, _ done: Bool) -> ()) {
        let storageRef = Storage.storage().reference(withPath: "userAvatars/\(userID).jpg")
        storageRef.getData(maxSize: 100000) { (data, error) in
            if error != nil {
                print("error while fetching image: \(String(describing: error!.localizedDescription))")
                handler(UIImage(named: "defaultProfileImage")!, true)
            } else {
                let avatarIMG = UIImage(data: data!)
                handler(avatarIMG!, true)
            }
        }
    }
    
    //getting users' emails when searching for new group members
    func getEmail(forSearchQuery query: String, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if email.contains(query) && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    //getting all IDs for a set of emails
    func getIds(forUserNames usernames: [String], handler: @escaping (_ uidArray: [String]) -> ()) {
        var idArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if usernames.contains(email) {
                    idArray.append(user.key)
                }
            }
            handler(idArray)
        }
    }
    
    //getting all emails for a selected group
    func getEmailsForGroup(group: Group, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if group.members.contains(user.key) {
                    let email = user.childSnapshot(forPath: "email").value as! String
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    //getting avatars for all group members
    func getAvatarsForGroup(group: Group, handler: @escaping (_ avatarDictionary: [String: UIImage], _ done: Bool) -> ()) {
        var avatarDictionary = [String: UIImage]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if group.members.contains(user.key) {
                    self.downloadUserAvatar(userID: user.key, handler: { (avatar, done) in
                        if done {
                            avatarDictionary[user.key] = avatar
                            if avatarDictionary.count == group.memberCount {
                                handler(avatarDictionary, true)
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    //GROUPS
    
    //adding a new group to database
    func createGroup(withTitle title: String, andDescription description: String, forUserIds ids: [String], handler: @escaping (_ groupCreated: Bool) -> ()) {
        REF_GROUPS.childByAutoId().updateChildValues(["title": title, "description": description, "members": ids])
        handler(true)
    }
    
    //getting all user's groups
    func getAllGroups(handler: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for group in groupSnapshot {
                let memberArray = group.childSnapshot(forPath: "members").value as! [String]
                if memberArray.contains((Auth.auth().currentUser?.uid)!) {
                    let title = group.childSnapshot(forPath: "title").value as! String
                    let description = group.childSnapshot(forPath: "description").value as! String
                    
                    let group = Group(title: title, description: description, key: group.key, members: memberArray, memberCount: memberArray.count)
                    groupsArray.append(group)
                }
            }
            handler(groupsArray)
        }
    }
    
    
    //MESSAGES
    
    //adding a Main Feed Post or a Group Post, based on whether the message has a group key
    func uploadPost(withMessage message: String, forUID uid: String, withGroupKey groupKey: String?, sendComplete: @escaping (_ status: Bool) -> ()) {
        if groupKey != nil {
            REF_GROUPS.child(groupKey!).child("messages").childByAutoId().updateChildValues(["content": message, "senderId": uid])
            sendComplete(true)
        } else {
            let time = ServerValue.timestamp()
            REF_FEED.childByAutoId().updateChildValues(["content": message, "senderId": uid, "time": time])
            sendComplete(true)
        }
    }
    
    //getting all Main Feed Messages
    func getAllFeedMessages(handler: @escaping (_ messages: [Message], _ done: Bool) -> ()) {
        var messageArray = [Message]()
        REF_FEED.observeSingleEvent(of: .value) { (feedMessageSnapshot) in
            guard let feedMessageSnapshot = feedMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for message in feedMessageSnapshot {
                let content  = message.childSnapshot(forPath: "content").value as! String
                let senderId = message.childSnapshot(forPath: "senderId").value as! String
                var timeStr = ""
                if let timeInt = message.childSnapshot(forPath: "time").value as? TimeInterval {
                    timeStr = TimeStampFormatter.instance.formatTime(timeInt)
                }
                let message = Message(content: content, senderId: senderId, time: timeStr)
                messageArray.append(message)
            }
            handler(messageArray, true)
        }
    }
    
    //getting all Group Messages
    func getAllMessagesFor(desiredGroup: Group, handler: @escaping (_ messagesArray: [Message]) -> ()) {
        var groupMessageArray = [Message]()
        REF_GROUPS.child(desiredGroup.key).child("messages").observeSingleEvent(of: .value) { (groupMessageSnapshot) in
            guard let groupMessageSnapshot = groupMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for groupMessage in groupMessageSnapshot {
                let content = groupMessage.childSnapshot(forPath: "content").value as! String
                let senderId = groupMessage.childSnapshot(forPath: "senderId").value as! String
                let time = ""
                let groupMessage = Message(content: content, senderId: senderId, time: time)
                groupMessageArray.append(groupMessage)
            }
            handler(groupMessageArray)
        }
    }
}

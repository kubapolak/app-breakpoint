//
//  CreateGroupsVC.swift
//  breakpoint
//
//  Created by Mac on 10/24/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupsVC: UIViewController {

    @IBOutlet weak var titleTextField: InsetTextField!
    
    @IBOutlet weak var descriptionTextField: InsetTextField!
    
    @IBOutlet weak var emailSearchTextField: InsetTextField!
    
    @IBOutlet weak var groupMemberLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var emailArray = [String]()
    var idArray = [String]()
    var avatarArray = [UIImage]()
    var chosenUserArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        emailSearchTextField.delegate = self
        emailSearchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.isHidden = true
        chosenUserArray = []
    }
    
    func clearArrays() {
        emailArray = []
        idArray = []
        avatarArray = []
    }
    
    @objc func textFieldDidChange() {
        clearArrays()
        tableView.reloadData()
        if emailSearchTextField.text == "" {
            tableView.reloadData()
        } else {
            searchForUsers()
            }
    }
    
    func searchForUsers() {
        let emailSearch = emailSearchTextField.text!
            DataService.instance.getEmail(forSearchQuery: emailSearch, handler: { (returnedEmailArray) in
                    self.emailArray = returnedEmailArray
                DataService.instance.getIds(forUserNames: self.emailArray, handler: { (returnedIds) in
                    self.idArray = returnedIds
                        self.tableView.reloadData()
                })
            })
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if titleTextField.text != "" && descriptionTextField.text != "" {
            DataService.instance.getIds(forUserNames: chosenUserArray, handler: { (idsArray) in
                var userIds = idsArray
                userIds.append((Auth.auth().currentUser?.uid)!)
                
                DataService.instance.createGroup(withTitle: self.titleTextField.text!, andDescription: self.descriptionTextField.text!, forUserIds: userIds, handler: { (groupCreated) in
                    if groupCreated {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("couldn't create group")
                    }
                })
            })
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension CreateGroupsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell else { return UITableViewCell() }
        
        var selected = Bool()
        if chosenUserArray.contains(cell.emailLabel.text!) {
            selected = true
        } else {
            selected = false
        }
        cell.configureCell(profileImage: UIImage(named: "defaultProfileImage")!, email: self.emailArray[indexPath.row], isSelected: selected)
        DispatchQueue.global(qos: .background).async {
            DataService.instance.downloadUserAvatar(userID: self.idArray[indexPath.row], handler: { (avatar, finished) in
                if finished {
                    DispatchQueue.main.async {
                        cell.profileImage.image = avatar
                    }
                }
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else { return }
        if !chosenUserArray.contains(cell.emailLabel.text!) {
            chosenUserArray.append(cell.emailLabel.text!)
            groupMemberLabel.text = chosenUserArray.joined(separator: ", ")
            doneButton.isHidden = false
        } else {
            chosenUserArray = chosenUserArray.filter({ $0 != cell.emailLabel.text! })
            if chosenUserArray.count >= 1 {
                groupMemberLabel.text = chosenUserArray.joined(separator: ", ")
            } else {
                groupMemberLabel.text = "add people to the group"
                doneButton.isHidden = true
            }
        }
    }
}

extension CreateGroupsVC: UITextFieldDelegate {
    
}

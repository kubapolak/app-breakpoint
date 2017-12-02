//
//  CreatePostVC.swift
//  breakpoint
//
//  Created by Mac on 10/24/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

//Adding a Main Feed post
class CreatePostVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        sendButton.bindToKeyboard()
        sendButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailLabel.text = Auth.auth().currentUser?.email
        profileImage.image = AuthService.avatar
        sendButton.setTitleColor(#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.6731592466), for: .disabled)
    }
    
    @IBAction func sendButtonWasPressed(_ sender: Any) {
        DataService.instance.uploadPost(withMessage: textView.text, forUID: (Auth.auth().currentUser?.uid)!, withGroupKey: nil, sendComplete: { (isComplete) in
            if isComplete {
                self.sendButton.isEnabled = true
                self.dismiss(animated: true, completion: nil)
            } else {
                self.sendButton.isEnabled = true
                print("there was an error")
            }
        })
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension CreatePostVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
}

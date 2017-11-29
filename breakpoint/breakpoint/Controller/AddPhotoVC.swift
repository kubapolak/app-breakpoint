//
//  AddPhotoVC.swift
//  breakpoint
//
//  Created by Mac on 10/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

//Adding an avatar
class AddPhotoVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var uploadingLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    var tempImg = UIImage()
    var tempImgData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        uploadingLabel.isHidden = true
        progressBar.isHidden = true
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupView() {
        self.profilePhoto.image = AuthService.avatar
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(AddPhotoVC.closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
    }
    
    @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func choosePhotoPressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        //mediaType default - still images
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        uploadingLabel.isHidden = false
        progressBar.isHidden = false
        uploadImageToFirebase(tempImgData, userID: (Auth.auth().currentUser?.uid)!)
        AuthService.avatar = tempImg
    }
    
    func uploadImageToFirebase(_ data: Data, userID: String) {
        let storageRef = Storage.storage().reference(withPath: "userAvatars/\(userID).jpg")
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        let uploadTask = storageRef.putData(data, metadata: uploadMetadata) { (metadata, error) in
            if error != nil {
                print("error while uploading image: \(String(describing: error?.localizedDescription))")
            } else {
                print("SUCCESS!, metadata: \(String(describing: metadata))")
                NotificationCenter.default.post(name: NOTIF_AVATAR_DID_CHANGE, object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
        //update the progress bar
        uploadTask.observe(.progress) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard let progress = snapshot.progress else { return }
            strongSelf.progressBar.progress = Float(progress.fractionCompleted)
        }
    }
}

extension AddPhotoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerEditedImage] as? UIImage, let imageData = UIImageJPEGRepresentation(originalImage, 0.1) {
            tempImgData = imageData
            tempImg = originalImage
        }
        self.profilePhoto.image = tempImg
        dismiss(animated: true, completion: nil)
    }
}

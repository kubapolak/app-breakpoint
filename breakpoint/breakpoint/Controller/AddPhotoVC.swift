//
//  AddPhotoVC.swift
//  breakpoint
//
//  Created by Mac on 10/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Firebase

class AddPhotoVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    func setupView() {
        
        DataService.instance.downloadUserAvatar(userID: (Auth.auth().currentUser?.uid)!) { (avatar) in
            self.profilePhoto.image = avatar
        }
        
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(AddPhotoVC.closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
    }
    
    @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func choosePhotoPressed(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        //mediaType default - still images
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(originalImage, 0.8) {
            uploadImageToFirebase(imageData, userID: (Auth.auth().currentUser?.uid)!)
        }
        dismiss(animated: true, completion: nil)
    }
}

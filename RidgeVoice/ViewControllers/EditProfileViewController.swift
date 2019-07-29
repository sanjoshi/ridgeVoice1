//
//  EditProfileViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/24/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import Realm

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var cPasswordTxt: UITextField!
    @IBOutlet weak var contactNoTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var typeTxt: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imagePicker = UIImagePickerController()
    var picker = UIPickerView()
    var imageDidChange: Bool = false
    
    lazy var userRef: DatabaseReference! = Database.database().reference().child("users")
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://ridgevoice-3768f.appspot.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            var contentRect = CGRect.zero
            for view in self.scrollView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            self.scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height + 10)
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        if validate() {
            self.view.endEditing(true)
            ActivityIndicator.shared.show(self.view)
            guard let uid = Auth.auth().currentUser?.uid else { return }
            self.userRef.child(uid).updateChildValues(["contactNo": self.contactNoTxt.text!, "address": self.addressTxt.text!])
//            self.userRef.child(uid).child("contactNo").setValue(self.contactNoTxt.text!)
//            self.userRef.child(uid).child("address").setValue(self.addressTxt.text!)
            if imageDidChange, let profileImg = self.profileImage.image, let imageData = profileImg.jpegData(compressionQuality: 0.8) {
                self.uploadImageToFirebaseStorage(data: imageData)
            } else {
                ActivityIndicator.shared.hide()
                self.confirmAlert()
            }
        }
    }
    
    func confirmAlert() {
        let alertController = UIAlertController(title: "Success", message: "Update succesfull.", preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { alert -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage(data : Data) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.putData(data, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL { url, error in
                    print("Success at: \(url?.absoluteString ?? "")")
                    if let imagePath = url?.absoluteString {
                        self.updateUserDetail(url: imagePath)
                    } else {
                        ActivityIndicator.shared.hide()
                    }
                }
            } else {
                ActivityIndicator.shared.hide()
                print("Failed")
            }
        }
    }
    
    func updateUserDetail(url: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = URL(string: url)
        changeRequest?.commitChanges(completion: { (error) in
            ActivityIndicator.shared.hide()
            if error == nil {
                //self.userRef.child(uid).child("profilePictureURL").setValue(url)
                self.userRef.child(uid).updateChildValues(["profilePictureURL": url])
                self.confirmAlert()
            } else {
                print("Error: \(error?.localizedDescription ?? "")")
                UIAlertController.show(self, "Error", "Try Again")
            }
        })
    }
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        contactNoTxt.attributedPlaceholder = NSAttributedString(string: "Enter your contact number", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        addressTxt.attributedPlaceholder = NSAttributedString(string: "Enter your address", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        if let currentUser = Auth.auth().currentUser {
            ActivityIndicator.shared.show(self.view)
            self.userRef.child(currentUser.uid).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                // Get user value
                if let value = snapshot.value as? NSDictionary {
                    print(value)
                    ActivityIndicator.shared.hide()
                    self?.passwordTxt.text = "123456"
                    self?.cPasswordTxt.text = "123456"
                    if let email = value["email"] as? String {
                        self?.emailTxt.text = email
                    }
                    if let fName = value["firstName"] as? String {
                        self?.firstNameTxt.text = fName
                    }
                    if let lName = value["lastName"] as? String {
                        self?.lastNameTxt.text = lName
                    }
                    if let type = value["type"] as? String {
                        self?.typeTxt.text = type
                    }
                    if let cNo = value["contactNo"] as? String {
                        self?.contactNoTxt.text = cNo
                    }
                    if let address = value["address"] as? String {
                        self?.addressTxt.text = address
                    }
                    if let picURL = value["profilePictureURL"] as? String {
                        self?.profileImage.sd_setImage(with: URL(string: picURL), placeholderImage: UIImage(named: "defaultUser"))
                    }
                }
                
            }) { (error) in
                ActivityIndicator.shared.hide()
                print(error.localizedDescription)
            }
        }
        
        emailTxt.setLeftPaddingPoints(10)
        passwordTxt.setLeftPaddingPoints(10)
        firstNameTxt.setLeftPaddingPoints(10)
        lastNameTxt.setLeftPaddingPoints(10)
        cPasswordTxt.setLeftPaddingPoints(10)
        contactNoTxt.setLeftPaddingPoints(10)
        addressTxt.setLeftPaddingPoints(10)
        typeTxt.setLeftPaddingPoints(10)
        imagePicker.delegate = self
        scrollView.delegate = self
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.editProfilePicture))
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        profileImage.roundedImage()
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func editProfilePicture()  {
        imagePicker.sourceType = .photoLibrary
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Photo Gallery", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self .present(imagePicker, animated: true, completion: nil)
        } else {
            UIAlertController.show(self, "Warning", "You don't have camera")
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
        unregisterNotifications()
    }
    
    @IBAction func cancelSignUp(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
            imageDidChange = true
            profileImage.roundedImage()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageDidChange = false
        dismiss(animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        if let contactTxt = contactNoTxt.text, !contactTxt.isEmptyOrWhitespace() && contactTxt.count != 10 {
            UIAlertController.show(self, "Error", "Invalid Contact Number")
            return false
        } else if let addressTxt = addressTxt.text, addressTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Address is mandatory")
            return false
        }
        return true
    }
}

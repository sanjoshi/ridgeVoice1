//
//  SignUpViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/9/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import Realm

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate {

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
    var userTypes: [String] = ["Owner" , "Tenant"]

    var imagePicker = UIImagePickerController()
    var picker = UIPickerView()
    
    lazy var userRef: DatabaseReference! = Database.database().reference().child("users")
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://ridgevoice-3768f.appspot.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
         updateUI()
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        if validate() {
            self.view.endEditing(true)
            ActivityIndicator.shared.show(self.view)
            Auth.auth().createUser(withEmail: emailTxt.text!, password: passwordTxt.text!) { (user, error) in
                if error != nil {
                    ActivityIndicator.shared.hide()
                    print(error!._code)
                    self.handleError(error!)   // use the handleError method
                    return
                }
                let newUser = User()
                newUser.id = user?.user.uid
                newUser.firstName = self.firstNameTxt.text!
                newUser.lastName = self.lastNameTxt.text!
                newUser.contactNo = self.contactNoTxt.text!
                newUser.email = self.emailTxt.text!
                newUser.type = self.typeTxt.text!
                newUser.address = self.addressTxt.text!
              
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = "\(self.firstNameTxt.text!) \(self.lastNameTxt.text!)"
                changeRequest?.commitChanges(completion: { (error) in
                    if error == nil {
                        print("success")
                        self.userRef.child((user?.user.uid)!).setValue(newUser.dictionaryRepresentation())
                        if let profileImg = self.profileImage.image, let imageData = profileImg.jpegData(compressionQuality: 0.8) {
                            self.uploadImageToFirebaseStorage(data: imageData)
                        }
                    } else {
                        ActivityIndicator.shared.hide()
                        print("error: \(error?.localizedDescription ?? "")")
                    }
                })
            }
        }
    }
    
    func uploadImageToFirebaseStorage(data : Data) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.putData(data, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL { url, error in
                    print("Success at: \(url?.absoluteString ?? "")") // success!
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
                self.userRef.child(uid).child("profilePictureURL").setValue(url)
                self.confirmAlert()
            } else {
                print("Error: \(error?.localizedDescription ?? "")")
                UIAlertController.show(self, "Error", "Try Again")
            }
        })
    }
    
    func confirmAlert() {
        let alertController = UIAlertController(title: "Success", message: "Registration succesfull.", preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { alert -> Void in
             self.dismiss(animated: true, completion: nil)
        })
         alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        emailTxt.attributedPlaceholder = NSAttributedString(string: "Enter your email id", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "Enter your password", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        firstNameTxt.attributedPlaceholder = NSAttributedString(string: "Enter your first name", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        lastNameTxt.attributedPlaceholder = NSAttributedString(string: "Enter your last name", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        cPasswordTxt.attributedPlaceholder = NSAttributedString(string: "Confirm password", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        contactNoTxt.attributedPlaceholder = NSAttributedString(string: "Enter your contact number", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        addressTxt.attributedPlaceholder = NSAttributedString(string: "Enter your address", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        typeTxt.attributedPlaceholder = NSAttributedString(string: "Select your type", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        emailTxt.setLeftPaddingPoints(10)
        passwordTxt.setLeftPaddingPoints(10)
        firstNameTxt.setLeftPaddingPoints(10)
        lastNameTxt.setLeftPaddingPoints(10)
        cPasswordTxt.setLeftPaddingPoints(10)
        contactNoTxt.setLeftPaddingPoints(10)
        addressTxt.setLeftPaddingPoints(10)
        typeTxt.setLeftPaddingPoints(10)
        imagePicker.delegate = self
        typeTxt.delegate = self
        scrollView.delegate = self
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.editProfilePicture))
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
    
    // PickerView
    func pickerVw(_ sender: UITextField) {
        picker = UIPickerView()
        picker.backgroundColor = UIColor.white
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputView = picker
        sender.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker() {
        self.view.endEditing(true)
        typeTxt.text = ""
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
            profileImage.roundedImage()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        if let nameTxt = firstNameTxt.text, nameTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "First name is mandatory")
            return false
        } else if let lastNameTxt = lastNameTxt.text, lastNameTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Last name is mandatory")
            return false
        } else if let emailTxt = emailTxt.text, emailTxt.isEmptyOrWhitespace() || !isValidEmail(testStr: emailTxt) {
            UIAlertController.show(self, "Error", "Invalid E-mail Id")
            return false
        } else if let passwordTxt = passwordTxt.text, passwordTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Password is mandatory")
            return false
        } else if let cpasswordTxt = cPasswordTxt.text, cpasswordTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Confirm Password is mandatory")
            return false
        } else if let cpasswordTxt = cPasswordTxt.text, let passwordTxt = passwordTxt.text, passwordTxt !=  cpasswordTxt {
            UIAlertController.show(self, "Error", "Password and Confirm Password does not match")
            return false
        } else if let contactTxt = contactNoTxt.text, !contactTxt.isEmptyOrWhitespace() && contactTxt.count != 10 {
            UIAlertController.show(self, "Error", "Invalid Contact Number")
            return false
        } else if let addressTxt = addressTxt.text, addressTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Address is mandatory")
            return false
        } else if let typeTxt = typeTxt.text, typeTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Type is mandatory")
            return false
        }
        
       return true
    }
}

extension SignUpViewController : UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTxt.text = userTypes[row]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typeTxt {
            self.pickerVw(textField)
        }
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
}

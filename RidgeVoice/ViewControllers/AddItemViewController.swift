//
//  AddItemViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 8/3/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import Realm

protocol updateItemDelegate: class {
    func updateItemDelegate()
}
class AddItemViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var stackImage: UIStackView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var buttonConstarint: NSLayoutConstraint!
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var contactNo: UITextField!
    @IBOutlet weak var titleText: UILabel!
    weak var itemDelegte: updateItemDelegate?
    var flag = 0
    var imageCounter = 0
    var imageDidChange_1: Bool = false
    var imageDidChange_2: Bool = false
    
    var isEdit: Bool?
    var ObjDetails: Item?
    lazy var sellItemRef: DatabaseReference! = Database.database().reference().child("SellItems")
    var imagePicker = UIImagePickerController()
    
   override func viewDidLoad() {
        super.viewDidLoad()
        if let isedit = isEdit, isedit {
            actionBtn.setTitle("Update", for: .normal)
            titleText.text = "Edit Item"
            if let messageObj = ObjDetails {
                txtView.text = messageObj.itemDesc
                nameText.text = messageObj.itemName
                priceText.text = messageObj.itemPrice
                contactNo.text = messageObj.contactDetails
                if let picURL1 = messageObj.itemImage1 {
                    imgView1.sd_setImage(with: URL(string: picURL1), placeholderImage: UIImage(named: "placeholderImage"))
                     imageDidChange_1 = true
                } else {
                    imgView1.image = UIImage(named: "placeholderImage")
                     imageDidChange_1 = false
                }
                if let picURL2 = messageObj.itemImage2 {
                    imgView2.sd_setImage(with: URL(string: picURL2), placeholderImage: UIImage(named: "placeholderImage"))
                     imageDidChange_2 = true
                } else {
                    imgView2.image = UIImage(named: "placeholderImage")
                     imageDidChange_2 = false
                }
            }
        } else {
            titleText.text = "Add Item"
            actionBtn.setTitle("Add", for: .normal)
        }
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerNotifications()
        if UIDevice.current.orientation.isLandscape {
            if UIDevice.current.hasNotch {
                buttonConstarint.constant = self.view.frame.width/2 + 100
            } else {
                buttonConstarint.constant = self.view.frame.width/2 + 50
            }
        } else {
            buttonConstarint.constant = 84
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            if UIDevice.current.hasNotch {
                buttonConstarint.constant = self.view.frame.width/2 + 100
            } else {
                buttonConstarint.constant = self.view.frame.width/2 + 50
            }
        } else {
            buttonConstarint.constant = 84
        }
        self.doneAction()
    }
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        stackImage.layer.borderColor = Color.navigation.value.cgColor
        stackImage.layer.borderWidth = 1.5
        imagePicker.delegate = self
        nameText.attributedPlaceholder = NSAttributedString(string: "Enter Title", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        priceText.attributedPlaceholder = NSAttributedString(string: "Enter Price", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        contactNo.attributedPlaceholder = NSAttributedString(string: "Enter Contact Number", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        if let isedit = isEdit, !isedit {
            txtView.text = "Description"
            txtView.textColor = UIColor.lightGray
        }
        txtView.delegate = self
        nameText.setLeftPaddingPoints(10)
        priceText.setLeftPaddingPoints(10)
        contactNo.setLeftPaddingPoints(10)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(doneAction))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        toolbar.setItems([doneButton], animated: false)
        txtView.inputAccessoryView = toolbar
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.editProfilePicture(recognizer:)))
        imgView1.tag = 1
        imgView1.addGestureRecognizer(tap)
        imgView1.isUserInteractionEnabled = true
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.editProfilePicture(recognizer:)))
        imgView2.tag = 2
        imgView2.addGestureRecognizer(tap1)
        imgView2.isUserInteractionEnabled = true
    }
    
    @objc func doneAction() {
        self.view.endEditing(true)
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        scrollView.scrollRectToVisible(.zero, animated: true)
        scrollView.contentOffset = .zero
    }
    
    @objc func editProfilePicture(recognizer: UITapGestureRecognizer)  {
        if recognizer.view?.tag == 1 {
            flag = 1
        } else if recognizer.view?.tag == 2 {
            flag = 2
        }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if flag == 1 {
                imgView1.image = image
                imageDidChange_1 = true
            }
            if flag == 2 {
                imgView2.image = image
                imageDidChange_2 = true
            }
        }
        flag = 0
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if flag == 1, let imagePlaceholder = UIImage(named: "placeholderImage"), let tmp = imgView1.image?.isEqualToImage(image: imagePlaceholder), tmp {
            imageDidChange_1 = false
        }
        if flag == 2, let imagePlaceholder = UIImage(named: "placeholderImage"), let tmp = imgView2.image?.isEqualToImage(image: imagePlaceholder), tmp {
             imageDidChange_2 = false
        }
        flag = 0
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func postAction(_ sender: UIButton) {
        if validate() {
            var itemID = ""
            if let isedit = isEdit, isedit {
                if let annObj = ObjDetails, let annId =  annObj.id {
                    itemID = annId
                }
            } else {
                if let key = sellItemRef.childByAutoId().key {
                    itemID = key
                }
            }
            self.view.endEditing(true)
            ActivityIndicator.shared.show(self.view)
            
            let currUser = Auth.auth().currentUser
            let user = User()
            user.id = currUser!.uid
            if let fullNameArr = currUser?.displayName?.components(separatedBy: " "), fullNameArr.count > 0 {
                if let fName = fullNameArr.first {
                    user.firstName = fName
                }
                if let lName = fullNameArr.last {
                    user.lastName = lName
                }
            }
            user.profilePictureURL = currUser?.photoURL?.absoluteString
            user.email = currUser?.email
           
            let itemObj = Item()
            itemObj.id = itemID
            itemObj.itemDesc = txtView.text
            itemObj.itemName = nameText.text
            itemObj.itemPrice = priceText.text
            itemObj.contactDetails = contactNo.text
            itemObj.user = user
            
            sellItemRef.child(itemID).setValue(itemObj.dictionaryRepresentation())
            
            if imageDidChange_1, let profileImg = self.imgView1.image, let imageData = profileImg.jpegData(compressionQuality: 0.8) {
                self.uploadImageToFirebaseStorage(data: imageData, imageId: "Item1_\(itemID)", itemId: itemID)
            } else {
                ActivityIndicator.shared.hide()
                self.dismiss(animated: true, completion: {
                    self.itemDelegte?.updateItemDelegate()
                })
            }
        }
    }
    
    func uploadImageToFirebaseStorage(data : Data, imageId: String, itemId: String) {
        let storageRef = Storage.storage().reference().child("SellItems/\(imageId)")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.putData(data, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL { url, error in
                    if let imagePath = url?.absoluteString {
                        self.updateMemberDetail(url: imagePath, imageId: imageId, itemId: itemId)
                    } else {
                        ActivityIndicator.shared.hide()
                    }
                }
            } else {
                ActivityIndicator.shared.hide()
                UIAlertController.show(self, "Error", "Error while uploading profile image.")
                print("Failed")
            }
        }
    }
    
    func updateMemberDetail(url: String, imageId: String, itemId: String) {
         let first5 = String(imageId.prefix(5))
        if first5 == "Item1" {
            self.sellItemRef.child(itemId).updateChildValues(["itemImage1": url])
        } else if first5 == "Item2" {
            self.sellItemRef.child(itemId).updateChildValues(["itemImage2": url])
        }
        if self.imageCounter == 0 {
            self.imageCounter = 1
            if imageDidChange_2, let profileImg = self.imgView2.image, let imageData = profileImg.jpegData(compressionQuality: 0.8) {
                self.uploadImageToFirebaseStorage(data: imageData, imageId: "Item2_\(itemId)", itemId: itemId)
            }
        } else  if self.imageCounter == 1 {
            ActivityIndicator.shared.hide()
            self.dismiss(animated: true, completion: {
                self.itemDelegte?.updateItemDelegate()
            })
        }
    }
    
    func validate() -> Bool {
        if let msgTxt = txtView.text, msgTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Description is mandatory")
            return false
        } else if let titleTxt = nameText.text, titleTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Title is mandatory")
            return false
        } else if let contactTxt = contactNo.text, !contactTxt.isEmptyOrWhitespace() && contactTxt.count != 10 {
            UIAlertController.show(self, "Error", "Invalid Contact Number")
            return false
        } else if let priceTxt = priceText.text, priceTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Price is mandatory")
            return false
        } else if imageDidChange_1 == false {
            UIAlertController.show(self, "Error", "Both Images are mandatory")
            return false
        } else if imageDidChange_2 == false {
            UIAlertController.show(self, "Error", "Both Images are mandatory")
            return false
        }
        return true
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension AddItemViewController: UITextFieldDelegate {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
        unregisterNotifications()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardSize = keyboardFrame.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        if txtView.isFirstResponder {
            if UIDevice.current.orientation.isLandscape {
                let tmpRect = CGRect(x: scrollView.frame.origin.x, y: txtView.frame.origin.y - 280, width: scrollView.frame.width, height: scrollView.frame.height)
                scrollView.scrollRectToVisible(tmpRect, animated: true)
            } else {
                let tmpRect = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y - 300, width: scrollView.frame.width, height: scrollView.frame.height)
                scrollView.scrollRectToVisible(tmpRect, animated: true)
            }
        }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        //scrollView.contentInset.bottom = 0
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        scrollView.scrollRectToVisible(.zero, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    @objc func updateTextView(notification : Notification) {
        if notification.name == UIResponder.keyboardWillHideNotification {
            txtView.contentInset = UIEdgeInsets.zero
        } else {
            txtView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            txtView.scrollIndicatorInsets = txtView.contentInset
        }
        txtView.scrollRangeToVisible(txtView.selectedRange)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            var contentRect = CGRect.zero
            for view in self.scrollView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            if UIDevice.current.orientation.isLandscape {
                self.scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height + 250)
            } else {
                self.scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height + 10)
            }
        }
    }
}

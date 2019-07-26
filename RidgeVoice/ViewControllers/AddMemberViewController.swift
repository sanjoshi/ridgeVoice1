//
//  AddMemberViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/13/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import Realm

protocol updateMembersDelegate: class {
    func updateMembersDelegate()
}

class AddMemberViewController: UIViewController, /*UIImagePickerControllerDelegate,UINavigationControllerDelegate*/ UIScrollViewDelegate {
   
    //@IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var contactTxt: UITextField!
    @IBOutlet weak var positionTxt: UITextField!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var buttonConstarint: NSLayoutConstraint!
    
    weak var memberDelegte: updateMembersDelegate?
    
   // var imagePicker = UIImagePickerController()
    var isEdit: Bool?
    var membersDetails: Member?
    //var imageDidChange: Bool = false
    lazy var memberRefObj: DatabaseReference! = Database.database().reference().child("Members")
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://ridgevoice-3768f.appspot.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let isedit = isEdit, isedit {
            actionBtn.setTitle("Update", for: .normal)
            titleTxt.text = "Edit Member"
            if let memberObj = membersDetails {
                nameTxt.text = memberObj.memberName
                contactTxt.text = memberObj.contactNo
                positionTxt.text = memberObj.position
                emailTxt.text = memberObj.memberEmail
                /*if let picURL = memberObj.memberPictureURL {
                     profileImage.sd_setImage(with: URL(string: picURL), placeholderImage: UIImage(named: "defaultUser"))
                }*/
            }
        } else {
             titleTxt.text = "Add Member"
            actionBtn.setTitle("Add", for: .normal)
        }
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UIDevice.current.orientation.isLandscape {
            buttonConstarint.constant = 200
        } else {
            buttonConstarint.constant = 84
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            buttonConstarint.constant = 200
        } else {
            buttonConstarint.constant = 84
        }
    }
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        nameTxt.attributedPlaceholder = NSAttributedString(string: "Enter member name", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        contactTxt.attributedPlaceholder = NSAttributedString(string: "Member contact number", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        positionTxt.attributedPlaceholder = NSAttributedString(string: "Member position", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        emailTxt.attributedPlaceholder = NSAttributedString(string: "Member Email", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        nameTxt.setLeftPaddingPoints(10)
        contactTxt.setLeftPaddingPoints(10)
        positionTxt.setLeftPaddingPoints(10)
        emailTxt.setLeftPaddingPoints(10)
        
        //imagePicker.delegate = self
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
        
       /* let tap = UITapGestureRecognizer(target: self, action: #selector(AddMemberViewController.editProfilePicture))
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        profileImage.roundedImage()*/
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    /*@objc func editProfilePicture()  {
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
            profileImage.image = image
            profileImage.roundedImage()
            imageDidChange = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }*/
    
    @IBAction func addMemberAction(_ sender: UIButton) {
        if validate() {
            var memberID = ""
            if let isedit = isEdit, isedit {
                if let member = membersDetails, let memberId =  member.id {
                    memberID = memberId
                }
            } else {
                if let key = memberRefObj.childByAutoId().key {
                    memberID = key
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
            
            let memberObj = Member()
            memberObj.id = memberID
            memberObj.memberName = nameTxt.text
            memberObj.contactNo = contactTxt.text
            memberObj.position = positionTxt.text
            memberObj.memberEmail = emailTxt.text
            memberObj.user = user
            memberObj.count.value = 0
            /*if let isedit = isEdit, isedit {
                let picURL = memberObj.memberPictureURL
                memberObj.memberPictureURL = picURL
            } else {
                memberObj.memberPictureURL = ""
            }*/
            memberObj.memberPictureURL = ""
            memberRefObj.child(memberID).setValue(memberObj.dictionaryRepresentation())
            ActivityIndicator.shared.hide()
            self.dismiss(animated: true, completion: {
                self.memberDelegte?.updateMembersDelegate()
            })
            /*if imageDidChange == true, let profileImg = self.profileImage.image, let imageData = profileImg.jpegData(compressionQuality: 0.8) {
                self.uploadImageToFirebaseStorage(data: imageData, imageId: memberID)
            } else {
                print("Image not updated")
                ActivityIndicator.shared.hide()
                self.dismiss(animated: true, completion: {
                    self.memberDelegte?.updateMembersDelegate()
                })
            }*/
        }
    }
    
    func uploadImageToFirebaseStorage(data : Data, imageId: String) {
        let storageRef = Storage.storage().reference().child("Members/\(imageId)")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.putData(data, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL { url, error in
                    if let imagePath = url?.absoluteString {
                        self.updateMemberDetail(url: imagePath, imageId: imageId)
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
    
    func updateMemberDetail(url: String, imageId: String) {
        self.memberRefObj.child(imageId).updateChildValues(["memberPictureURL": url])
        ActivityIndicator.shared.hide()
        self.dismiss(animated: true, completion: {
            self.memberDelegte?.updateMembersDelegate()
        })
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func validate() -> Bool {
        if let nameTxt = nameTxt.text, nameTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Member name is mandatory")
            return false
        } else if let contactTxt = contactTxt.text, !contactTxt.isEmptyOrWhitespace() && contactTxt.count != 10 {
            UIAlertController.show(self, "Error", "Invalid Contact Number")
            return false
        } else if let positionTxt = positionTxt.text, positionTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Position is mandatory")
            return false
        } else if let emailTxt = emailTxt.text, emailTxt.isEmptyOrWhitespace() || !isValidEmail(testStr: emailTxt) {
            UIAlertController.show(self, "Error", "Invalid email Id")
            return false
        }
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func calculateContentSize(scrollView: UIScrollView) -> CGSize {
        var topPoint = CGFloat()
        var height = CGFloat()
        
        for subview in scrollView.subviews {
            if subview.frame.origin.y > topPoint {
                topPoint = subview.frame.origin.y
                height = subview.frame.size.height
            }
        }
        return CGSize(width: scrollView.frame.size.width, height: height + topPoint)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

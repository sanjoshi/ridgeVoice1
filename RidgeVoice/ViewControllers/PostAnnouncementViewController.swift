//
//  PostAnnouncementViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/14/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase

protocol updateAnnoucementDelegate: class {
    func updateAnnoucementDelegate()
}

class PostAnnouncementViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var buttonConstarint: NSLayoutConstraint!
    weak var annDelegte: updateAnnoucementDelegate?
    
    var isEdit: Bool?
    var ObjDetails: Announcement?
    lazy var annRefObj: DatabaseReference! = Database.database().reference().child("Announcements")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let isedit = isEdit, isedit {
            postBtn.setTitle("Update", for: .normal)
            if let messageObj = ObjDetails {
               txtView.text = messageObj.messageDesc
               titleText.text = messageObj.message
            }
        } else {
            postBtn.setTitle("Post", for: .normal)
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
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        titleText.attributedPlaceholder = NSAttributedString(string: "Enter member name", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
         if let isedit = isEdit, !isedit {
            txtView.text = "Description"
            txtView.textColor = UIColor.lightGray
        }
        txtView.delegate = self
        titleText.setLeftPaddingPoints(10)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
         toolbar.setItems([doneButton], animated: false)
        txtView.inputAccessoryView = toolbar
    }
    
    @objc func doneAction() {
       self.view.endEditing(true)
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
            var annoucementID = ""
            if let isedit = isEdit, isedit {
                if let annObj = ObjDetails, let annId =  annObj.id {
                    annoucementID = annId
                }
            } else {
                if let key = annRefObj.childByAutoId().key {
                    annoucementID = key
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
            let createdAt = CreatedAt().getCurrentTime()
            let annObj = Announcement()
            annObj.id = annoucementID
            annObj.messageDesc = txtView.text
            annObj.message = titleText.text
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            let dateString = formatter.string(from:date)
            annObj.dateValue = dateString
            print (date)
            annObj.user = user
            
            annObj.timeStamp = "\(createdAt.year)\(String(format: "%02d", createdAt.month))\(String(format: "%02d", createdAt.date))\(createdAt.hours)\(String(format: "%02d", createdAt.minutes))\(String(format: "%02d", createdAt.seconds))"
            
            annRefObj.child(annoucementID).setValue(annObj.dictionaryRepresentation())
            ActivityIndicator.shared.hide()
            self.dismiss(animated: true, completion: {
                self.annDelegte?.updateAnnoucementDelegate()
            })
        }
    }
    
    func validate() -> Bool {
        if let msgTxt = txtView.text, msgTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Message is mandatory")
            return false
        } else if let titleTxt = titleText.text, titleTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Title is mandatory")
            return false
        }
        return true
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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

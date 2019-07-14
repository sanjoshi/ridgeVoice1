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
    weak var annDelegte: updateAnnoucementDelegate?
    
    var isEdit: Bool?
    var ObjDetails: Announcement?
    lazy var annRefObj: DatabaseReference! = Database.database().reference().child("Announcements")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let isedit = isEdit, isedit {
            postBtn.setTitle("Update", for: .normal)
            if let messageObj = ObjDetails {
               txtView.text = messageObj.message
            }
        } else {
            postBtn.setTitle("Add", for: .normal)
        }
        updateUI()
    }
    
    func updateUI() {
         if let isedit = isEdit, !isedit {
            txtView.text = "Placeholder"
            txtView.textColor = UIColor.lightGray
        }
        txtView.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
         toolbar.setItems([doneButton], animated: false)
        txtView.inputAccessoryView = toolbar
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
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
            textView.text = "Placeholder"
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
            user.name = currUser?.displayName
            user.profilePictureURL = currUser?.photoURL?.absoluteString
            user.email = currUser?.email
            let createdAt = CreatedAt().getCurrentTime()
            let annObj = Announcement()
            annObj.id = annoucementID
            annObj.message = txtView.text
            
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

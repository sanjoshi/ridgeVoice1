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
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        titleText.attributedPlaceholder = NSAttributedString(string: "Enter Title", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
         if let isedit = isEdit, !isedit {
            txtView.text = "Description"
            txtView.textColor = UIColor.lightGray
        }
        txtView.delegate = self
        titleText.setLeftPaddingPoints(10)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(doneAction))
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
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        scrollView.scrollRectToVisible(.zero, animated: true)
        scrollView.contentOffset = .zero
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
extension PostAnnouncementViewController {
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
}

//
//  AddServiceViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 8/4/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase

protocol serviceAddedDelegate: class {
    func serviceAddedDelegate()
}

class AddServiceViewController: UIViewController {
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var serviceText: UITextField!
    @IBOutlet weak var contactText: UITextField!
    @IBOutlet weak var buttonConstarint: NSLayoutConstraint!
    @IBOutlet weak var titleText: UILabel!
    weak var serDelegte: serviceAddedDelegate?
    
    var isEdit: Bool?
    var ObjDetails: Service?
    lazy var serviceRefObj: DatabaseReference! = Database.database().reference().child("Service")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let isedit = isEdit, isedit {
            titleText.text = "Edit Service Info"
            postBtn.setTitle("Update", for: .normal)
            if let messageObj = ObjDetails {
                nameText.text = messageObj.name
                serviceText.text = messageObj.service
                contactText.text = messageObj.contact
            }
        } else {
            titleText.text = "Add Service Info"
            postBtn.setTitle("Add", for: .normal)
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
        nameText.attributedPlaceholder = NSAttributedString(string: "Enter name", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        serviceText.attributedPlaceholder = NSAttributedString(string: "Enter service", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        contactText.attributedPlaceholder = NSAttributedString(string: "Enter contact", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        nameText.setLeftPaddingPoints(10)
        serviceText.setLeftPaddingPoints(10)
        contactText.setLeftPaddingPoints(10)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(doneAction))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
    }
    
    @objc func doneAction() {
        self.view.endEditing(true)
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        scrollView.scrollRectToVisible(.zero, animated: true)
        scrollView.contentOffset = .zero
    }
    
    @IBAction func postAction(_ sender: UIButton) {
        if validate() {
            var serviceID = ""
            if let isedit = isEdit, isedit {
                if let annObj = ObjDetails, let annId =  annObj.id {
                    serviceID = annId
                }
            } else {
                if let key = serviceRefObj.childByAutoId().key {
                    serviceID = key
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
            let serviceObj = Service()
            serviceObj.id = serviceID
            serviceObj.name = nameText.text
            serviceObj.service = serviceText.text
            serviceObj.contact = contactText.text
            serviceObj.user = user
            
            serviceRefObj.child(serviceID).setValue(serviceObj.dictionaryRepresentation())
            ActivityIndicator.shared.hide()
            self.dismiss(animated: true, completion: {
                self.serDelegte?.serviceAddedDelegate()
            })
        }
    }
    
    func validate() -> Bool {
        if let nameTxt = nameText.text, nameTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Name is mandatory")
            return false
        } else if let serTxt = serviceText.text, serTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Service is mandatory")
            return false
        } else if let contactTxt = contactText.text, !contactTxt.isEmptyOrWhitespace() && contactTxt.count != 10 {
            UIAlertController.show(self, "Error", "Invalid Contact Number")
            return false
        }
        return true
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
 }

extension AddServiceViewController {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
        unregisterNotifications()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        scrollView.scrollRectToVisible(.zero, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

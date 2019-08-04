//
//  AddIssuesViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 8/2/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import Realm

protocol updateIssuesDelegate: class {
    func updateIssuesDelegate()
}
class AddIssuesViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var typeText: UITextField!
    @IBOutlet weak var buttonConstarint: NSLayoutConstraint!
    var issueTypes: [String] = ["Plumbing", "Electrical", "Appliances", "Heating and Air Conditioning", "Other service"]
    weak var issueDelegte: updateIssuesDelegate?
    
    var isEdit: Bool?
    var ObjDetails: RidgeIssues?
    lazy var ridgeIssueRef: DatabaseReference! = Database.database().reference().child("RidgeIssues")
    var picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let isedit = isEdit, isedit {
            actionBtn.setTitle("Update", for: .normal)
            if let messageObj = ObjDetails {
                txtView.text = messageObj.issueDesc
                titleText.text = messageObj.issueTitle
                typeText.text = messageObj.issueType
            }
        } else {
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
        titleText.attributedPlaceholder = NSAttributedString(string: "Enter Title", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        typeText.attributedPlaceholder = NSAttributedString(string: "Select Type", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium) ])
        
        if let isedit = isEdit, !isedit {
            txtView.text = "Description"
            txtView.textColor = UIColor.lightGray
        }
        txtView.delegate = self
        titleText.setLeftPaddingPoints(10)
        typeText.delegate = self
        typeText.setLeftPaddingPoints(10)
        
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
    
    @objc func tap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func postAction(_ sender: UIButton) {
        if validate() {
            var issueID = ""
            if let isedit = isEdit, isedit {
                if let annObj = ObjDetails, let annId =  annObj.id {
                    issueID = annId
                }
            } else {
                if let key = ridgeIssueRef.childByAutoId().key {
                    issueID = key
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
            let issueObj = RidgeIssues()
            issueObj.id = issueID
            issueObj.issueDesc = txtView.text
            issueObj.issueTitle = titleText.text
            issueObj.issueType = typeText.text
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            let dateString = formatter.string(from:date)
            issueObj.issueDate = dateString
            print (date)
            issueObj.user = user
            
            issueObj.timeStamp = "\(createdAt.year)\(String(format: "%02d", createdAt.month))\(String(format: "%02d", createdAt.date))\(createdAt.hours)\(String(format: "%02d", createdAt.minutes))\(String(format: "%02d", createdAt.seconds))"
            
            ridgeIssueRef.child(issueID).setValue(issueObj.dictionaryRepresentation())
            ActivityIndicator.shared.hide()
            self.dismiss(animated: true, completion: {
                self.issueDelegte?.updateIssuesDelegate()
            })
        }
    }
    
    func validate() -> Bool {
        if let msgTxt = txtView.text, msgTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Description is mandatory")
            return false
        } else if let titleTxt = titleText.text, titleTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Title is mandatory")
            return false
        } else if let typeTxt = typeText.text, typeTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Type is mandatory")
            return false
        }
        return true
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddIssuesViewController: UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate {
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
        typeText.text = ""
    }
    
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return issueTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return issueTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeText.text = issueTypes[row]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typeText {
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
            if UIDevice.current.orientation.isLandscape {
                self.scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height + 250)
            } else {
                self.scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height + 10)
            }
        }
    }
}

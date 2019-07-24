//
//  LoginViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/9/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import Realm
import RealmSwift

class LoginViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var loginTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var currUser = Auth.auth().currentUser
    lazy var userRef: DatabaseReference! = Database.database().reference().child("users")

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        scrollView.contentOffset = .zero
    }
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        loginTxt.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium) ])
        
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium) ])
        
        loginTxt.setLeftPaddingPoints(10)
        passwordTxt.setLeftPaddingPoints(10)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func resetPasswordAction(sender : AnyObject) {
        let alertController = UIAlertController(title: "Reset Password", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter your email"
        }
        let saveAction = UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            self.resetPassword(emailAddress: firstTextField.text ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func resetPassword(emailAddress: String) {
        if emailAddress.isEmptyOrWhitespace() || !isValidEmail(testStr: emailAddress) {
            UIAlertController.show(self, "Error", "Invalid E-mail Id")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: emailAddress) { error in
            if let err = error {
                 print("Error: \(err)")
            }
        }
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "signupvc") as? SignUpViewController {
            self.present(signUpVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        if let loginTxt = loginTxt.text, loginTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Email is mandatory")
            return
        } else if let passwordTxtField = passwordTxt.text, passwordTxtField.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Password is incorrect")
            return
        } else if let loginTxt = loginTxt.text, !isValidEmail(testStr: loginTxt) {
            UIAlertController.show(self, "Error", "Invalid Email Id.")
            return
        } else {
            self.view.endEditing(true)
            ActivityIndicator.shared.show(self.view)
            Auth.auth().signIn(withEmail: loginTxt.text!, password: passwordTxt.text!, completion: { (user, error) in
                if error != nil {
                    ActivityIndicator.shared.hide()
                    print(error!._code)
                    self.handleError(error!) 
                    return
                } else {
                    print("login successful")
                    if let currentUser = Auth.auth().currentUser {
                        self.userRef.child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            // Get user value
                            if let value = snapshot.value as? NSDictionary {
                                print(value)
                                ActivityIndicator.shared.hide()
                                //self.removeRealmData()
                                let defaults = UserDefaults.standard
                                if let type = value["type"] as? String, type == "Admin" {
                                    defaults.set(true, forKey: "isAdmin")
                                } else {
                                    // defaults.set(false, forKey: "isAdmin")
                                     defaults.set(true, forKey: "isAdmin")
                                }
                                defaults.set(true, forKey: "userLoggedIn")
                                defaults.synchronize()
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let dashboardVC = storyboard.instantiateViewController(withIdentifier: "dashboardvc")
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = dashboardVC
                            }
                            
                        }) { (error) in
                            ActivityIndicator.shared.hide()
                            print(error.localizedDescription)
                        }
                    } else {
                        ActivityIndicator.shared.hide()
                    }
                }
            })
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            var contentRect = CGRect.zero
            for view in self.scrollView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            print("subviews: \(self.scrollView.subviews.count)")
            self.scrollView.contentSize = contentRect.size
            print("content size: \(self.scrollView.contentSize)")
            print("view frame-2: \(self.view.frame)")
        }
    }
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    /*func removeRealmData() {
        let realm = try! Realm()
        let allObjects = realm.objects(Member.self)
        
        try! realm.write {
            realm.delete(allObjects)
        }
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

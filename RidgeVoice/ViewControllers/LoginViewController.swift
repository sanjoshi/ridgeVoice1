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

class LoginViewController: UIViewController {
    @IBOutlet weak var loginTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    var currUser = Auth.auth().currentUser
    lazy var userRef: DatabaseReference! = Database.database().reference().child("users")

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        loginTxt.attributedPlaceholder = NSAttributedString(string: "Email Id", attributes: [
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
    @IBAction func signUpAction(_ sender: UIButton) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "signupvc") as? SignUpViewController {
            self.present(signUpVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        /*if let loginTxt = loginTxt.text, loginTxt.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Email is mandatory")
            return
        } else if let passwordTxtField = passwordTxt.text, passwordTxtField.isEmptyOrWhitespace() {
            UIAlertController.show(self, "Error", "Password is incorrect")
            return
        } else if let loginTxt = loginTxt.text, !isValidEmail(testStr: loginTxt) {
            UIAlertController.show(self, "Error", "Invalid Email Id.")
            return
        } else {*/
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
                                self.removeRealmData()
                                let defaults = UserDefaults.standard
                                if let type = value["type"] as? String, type == "Admin" {
                                    defaults.set(true, forKey: "isAdmin")
                                }
                                defaults.set(true, forKey: "userLoggedIn")
                                defaults.synchronize()
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let dashboardVC = storyboard.instantiateViewController(withIdentifier: "dashboardvc")
                                UIApplication.shared.keyWindow?.rootViewController = dashboardVC
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
        //}
        
    }
    
    func removeRealmData() {
        let realm = try! Realm()
        let allObjects = realm.objects(Member.self)
        
        try! realm.write {
            realm.delete(allObjects)
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

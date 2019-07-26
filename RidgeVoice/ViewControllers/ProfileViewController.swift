//
//  ProfileViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 12/07/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import RealmSwift

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    lazy var userRef: DatabaseReference! = Database.database().reference().child("users")
    var users: [User] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    var shouldShowMyProfile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
      }

    override func viewWillAppear(_ animated: Bool) {
        self.users.removeAll()
        fetchUserExceptCurrent()
    }
    
    @IBAction func signoutAction(_ sender: UIButton) {
        if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginvc") as? LoginViewController {
            let navigationController = UINavigationController(rootViewController: loginVC)
            navigationController.isNavigationBarHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navigationController
        }
    }
    
    func  updateUI() {
        view.backgroundColor = Color.background.value
        self.title = "Profile"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        if shouldShowMyProfile {
            topViewHeight.constant = 0
            let barButtonItem = UIBarButtonItem(title: "My Profile", style: .plain, target: self, action: #selector(addTapped))
            barButtonItem.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 17)!,
                NSAttributedString.Key.foregroundColor: UIColor.white
                ], for: .normal)
            navigationItem.rightBarButtonItem = barButtonItem
        } else {
            topView.backgroundColor = Color.navigation.value
            topViewHeight.constant = 44
        }
        
        self.tableView.reloadData()
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editProfileVC = storyboard.instantiateViewController(withIdentifier: "editprofilevc") as? EditProfileViewController {
            self.present(editProfileVC, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count > 0 {
             return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "profilecellidentifier", for: indexPath) as? ProfileTableViewCell {
            let str = "\(users[indexPath.section].address ?? "")\n\(users[indexPath.section].contactNo ?? "")\n\(users[indexPath.section].email ?? "")"
            cell.profileTxt.text = str
            if let picURL = users[indexPath.section].profilePictureURL {
                cell.profileImg.sd_setImage(with: URL(string: picURL), placeholderImage: UIImage(named: "defaultUser"))
            } else {
                cell.profileImg.image = UIImage(named: "defaultUser")
            }
            
            return cell
        }
        return UITableViewCell()
       
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(users[section].firstName ?? "") \(users[section].lastName ?? "")"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !shouldShowMyProfile {
            self.didSelectContact(userObj: users[indexPath.row])
        }
    }
    
    func didSelectContact(userObj: User) {
        guard let uid = userObj.id else { return }
        let alert = UIAlertController(title: "Ridge Voice", message: "Select User Type", preferredStyle: UIAlertController.Style.actionSheet)
        let admin = UIAlertAction(title: "Admin", style: UIAlertAction.Style.default) { (UIAlertAction) in
             self.userRef.child(uid).child("type").setValue("Admin")
        }
        let tenant = UIAlertAction(title: "Tenant", style: UIAlertAction.Style.default) { (UIAlertAction) in
             self.userRef.child(uid).child("type").setValue("Tenant")
        }
        
        let owner = UIAlertAction(title: "Owner", style: UIAlertAction.Style.default) { (UIAlertAction) in
             self.userRef.child(uid).child("type").setValue("Owner")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(admin)
        alert.addAction(tenant)
        alert.addAction(owner)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
   func fetchUserExceptCurrent() {
        ActivityIndicator.shared.show(self.view)
        let currentUser = Auth.auth().currentUser?.uid
        userRef.observe(DataEventType.value, with: { (snapshot) in
        ActivityIndicator.shared.hide()
        if let dictionary = snapshot.value as? [String: AnyObject] {
             self.users.removeAll()
            for userObj in dictionary {
                if let userDict = userObj.value as? NSDictionary, let userid = userDict["id"] as? String, currentUser != userid {
                    let user = User()
                    user.id = userDict["id"] as? String
                    user.firstName = userDict["firstName"] as? String
                    user.lastName = userDict["lastName"] as? String
                    user.email = userDict["email"] as? String
                    user.contactNo = userDict["contactNo"] as? String
                    user.address = userDict["address"] as? String
                    user.profilePictureURL = userDict["profilePictureURL"] as? String
                    self.users.append(user)
                }
            }
            self.users = self.users.sorted(by: { (($0 as AnyObject).firstName as String?) ?? "" < (($1 as AnyObject).firstName as String?) ?? "" })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
            }){ (error) in
                ActivityIndicator.shared.hide()
                print(error.localizedDescription)
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

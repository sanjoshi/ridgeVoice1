//
//  ViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/9/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import Realm

class ViewController: UIViewController {
    
    lazy var annRef: DatabaseReference! = Database.database().reference().child("Announcements")
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://ridgevoice-3768f.appspot.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Home"
        loadPosts()
        view.backgroundColor = Color.background.value
    }
    
    @IBAction func addAction(_ sender: Any) {
        if let key = annRef.childByAutoId().key {
            let currUser = Auth.auth().currentUser
            let user = User()
            user.id = currUser!.uid
            user.name = currUser?.displayName
            user.profilePictureURL = currUser?.photoURL?.absoluteString
            user.email = currUser?.email
            let userPost = Announcements()
            userPost.id = key
            if user.type == "Admin" {
                userPost.isAdmin = true
            } else {
                userPost.isAdmin = false
            }
            userPost.user = user
            annRef.child(key).setValue(userPost.dictionaryRepresentation())
            print("Dict: \n\(userPost.dictionaryRepresentation())")
        }
    }
    
    func loadPosts() {
        annRef?.observe(DataEventType.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {
                print(dictionary)
//                let post = self.userPostInitialize(dictionary: dictionary)
//                post.writeToRealm()
//                self.loadDataFromRealm()
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            }
        }){ (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}


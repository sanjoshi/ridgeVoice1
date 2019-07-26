//
//  BoardMembersVC.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 12/07/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import SDWebImage

class BoardMembersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    lazy var memberRef: DatabaseReference! = Database.database().reference().child("Members")
    var members: Results<Member>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        ActivityIndicator.shared.show(self.view)
        memberRef.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.exists() {
                self.loadMembersData()
            } else {
                ActivityIndicator.shared.hide()
            }
        }){ (error) in
            ActivityIndicator.shared.hide()
            print(error.localizedDescription)
        }
    }
    
   func  updateUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = Color.background.value
        self.title = "Board Members"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        self.navigationController!.navigationBar.tintColor = UIColor.white
        if UserDefaults.standard.bool(forKey: "isAdmin") {
            let barButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
            barButtonItem.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 17)!,
                NSAttributedString.Key.foregroundColor: UIColor.white
                ], for: .normal)
            navigationItem.rightBarButtonItem = barButtonItem
       }
        self.tableView.reloadData()
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addMemberVC = storyboard.instantiateViewController(withIdentifier: "addmembervc") as? AddMemberViewController {
            addMemberVC.isEdit = false
            addMemberVC.memberDelegte = self
            addMemberVC.membersDetails = nil
            self.present(addMemberVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = members {
            return members.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "boardcell", for: indexPath) as? BoardTableViewCell {
            cell.nameTxt.text = members[indexPath.row].memberName
            cell.positionTxt.text = members[indexPath.row].position
            cell.contactTxt.text = members[indexPath.row].contactNo
            cell.emailTxt.text = members[indexPath.row].memberEmail
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addMemberVC = storyboard.instantiateViewController(withIdentifier: "addmembervc") as? AddMemberViewController {
                addMemberVC.isEdit = true
                addMemberVC.membersDetails = self.members[indexPath.row]
                addMemberVC.memberDelegte = self
                self.present(addMemberVC, animated: true, completion: nil)
            }
        }
        editAction.backgroundColor = Color.navigation.value
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            if let memberId = self.members[indexPath.row].id {
                 self.memberRef.child(memberId).removeValue()
                let memberObj = memberRealm.objects(Member.self).filter({ (member) -> Bool in
                    return member.id == memberId
                })
                print("count: \(memberObj.count)")
                if let realm = try? Realm() {
                    realm.beginWrite()
                    realm.delete(memberObj)
                    do {
                        try realm.commitWrite() // This seems to fail sometimes
                        self.loadDataFromRealm()
                    } catch {
                        print("Error while deleting object")
                    }
                }
       }
    }
        deleteAction.backgroundColor = .red
        return [editAction,deleteAction]
    }
    
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if UserDefaults.standard.bool(forKey: "isAdmin") {
            return true
        }
        return false
    }
}

extension BoardMembersVC: updateMembersDelegate {
    func updateMembersDelegate() {
        self.loadMembersData()
    }
    
    func memberInitialize(dictionary: NSDictionary) -> Member {
        let memberObj = Member()
        memberObj.id = dictionary["id"] as? String
        if let dictObj = dictionary["user"] as? NSDictionary {
            memberObj.user = userInitialize(dictionary: dictObj)
        }
        memberObj.memberName = dictionary["memberName"] as? String
        memberObj.contactNo = dictionary["contactNo"] as? String
        memberObj.position = dictionary["position"] as? String
        memberObj.memberPictureURL = "" //dictionary["memberPictureURL"] as? String
        memberObj.memberEmail = dictionary["memberEmail"] as? String
        return memberObj
    }
    
    func userInitialize(dictionary: NSDictionary) -> User {
        let user = User()
        user.id = dictionary["id"] as? String
        user.firstName = dictionary["firstName"] as? String
        user.lastName = dictionary["lastName"] as? String
        user.email = dictionary["email"] as? String
        user.profilePictureURL = dictionary["profilePictureURL"] as? String
        return user
    }
    
    func loadMembersData() {
        if self.visibleViewController is BoardMembersVC {
            ActivityIndicator.shared.show(self.view)
            memberRef.observe(DataEventType.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? NSDictionary {
                    let post = self.memberInitialize(dictionary: dictionary)
                    post.writeToRealm()
                    self.loadDataFromRealm()
                } else {
                    ActivityIndicator.shared.hide()
                }
            }){ (error) in
                ActivityIndicator.shared.hide()
                print(error.localizedDescription)
            }
        }
    }
    
    func loadDataFromRealm() {
         if self.visibleViewController is BoardMembersVC {
            members = memberRealm.objects(Member.self).sorted(byKeyPath: "memberName",ascending: true)
            DispatchQueue.main.async {
                ActivityIndicator.shared.hide()
                self.tableView.reloadData()
            }
        }
    }
}

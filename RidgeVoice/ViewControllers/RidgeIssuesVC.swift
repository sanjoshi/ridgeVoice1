//
//  RidgeIssuesVC.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 12/07/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import PMAlertController

class RidgeIssuesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, updateIssuesDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var ridgeIssueRef: DatabaseReference! = Database.database().reference().child("RidgeIssues")
    var ridgeIssuesArr: Results<RidgeIssues>!
    let nsformatter = DateFormatter()
    let loggedUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        ActivityIndicator.shared.show(self.view)
        ridgeIssueRef.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.exists() {
                self.loadAnnouncements()
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
        self.title = "Ridge Issues"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        self.navigationController!.navigationBar.tintColor = UIColor.white
            let barButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
            barButtonItem.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 17)!,
                NSAttributedString.Key.foregroundColor: UIColor.white
                ], for: .normal)
            navigationItem.rightBarButtonItem = barButtonItem
        self.tableView.reloadData()
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addAnnVC = storyboard.instantiateViewController(withIdentifier: "addissuevc") as? AddIssuesViewController {
            addAnnVC.isEdit = false
            addAnnVC.issueDelegte = self
            addAnnVC.ObjDetails = nil
            self.present(addAnnVC, animated: true, completion: nil)
        }
    }
    
    func updateIssuesDelegate() {
        self.loadAnnouncements()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = ridgeIssuesArr {
            return ridgeIssuesArr.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "announcementcell", for: indexPath) as? AnnouncementTableViewCell {
            let formattedString = NSMutableAttributedString()
            if let msg = ridgeIssuesArr[indexPath.row].issueTitle, !msg.isEmptyOrWhitespace() {
                let myAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
                let myString = NSMutableAttributedString(string: "\(msg) \n", attributes: myAttribute )
                formattedString.append(myString)
            }
            if let desc = ridgeIssuesArr[indexPath.row].issueType, !desc.isEmptyOrWhitespace() {
                formattedString.normal(desc)
            }
            cell.mainTxt.attributedText = formattedString
            if let dateObj = ridgeIssuesArr[indexPath.row].issueDate {
                cell.dateTxt.text = "Date: \(dateObj)"
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addAnnVC = storyboard.instantiateViewController(withIdentifier: "addissuevc") as? AddIssuesViewController {
                addAnnVC.isEdit = true
                addAnnVC.issueDelegte = self
                addAnnVC.ObjDetails = self.ridgeIssuesArr[indexPath.row]
                self.present(addAnnVC, animated: true, completion: nil)
            }
        }
        editAction.backgroundColor = Color.navigation.value
        /*let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            if let annId = self.ridgeIssuesArr[indexPath.row].id {
                self.announcementRef.child(annId).removeValue()
                let annObj = annRealm.objects(Announcement.self).filter({ (annoucementObj) -> Bool in
                    return annoucementObj.id == annId
                })
                if let realm = try? Realm() {
                    realm.beginWrite()
                    realm.delete(annObj)
                    do {
                        try realm.commitWrite()
                        self.loadDataFromRealm()
                    } catch {
                        print("Error while deleting object")
                    }
                }
            }
        }
        deleteAction.backgroundColor = .red*/
        return [editAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let userObj = ridgeIssuesArr[indexPath.row].user, let userId = userObj.id, loggedUser?.uid == userId {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showPopup(issueObj: ridgeIssuesArr[indexPath.row])
    }
    
    func showPopup(issueObj: RidgeIssues) {
        let alertVC = PMAlertController(title: issueObj.issueTitle, description: issueObj.issueDesc, image: nil, style: .alert)
        alertVC.gravityDismissAnimation = false
        
       alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
            //print("Capture action OK")
        }))
        alertVC.view.tintColor = Color.navigation.value
        self.present(alertVC, animated: true, completion: nil)
    }
    
}

extension RidgeIssuesVC {
    func updateAnnoucementDelegate() {
        self.loadAnnouncements()
    }
    
    func annInitialize(dictionary: NSDictionary) -> RidgeIssues {
        let annObj = RidgeIssues()
        annObj.id = dictionary["id"] as? String
        if let dictObj = dictionary["user"] as? NSDictionary {
            annObj.user = userInitialize(dictionary: dictObj)
        }
        annObj.issueTitle = dictionary["issueTitle"] as? String
        annObj.issueType = dictionary["issueType"] as? String
        annObj.issueDesc = dictionary["issueDesc"] as? String
        if let datestr = dictionary["issueDate"] as? String {
            annObj.issueDate = datestr
        }
        annObj.timeStamp = dictionary["timeStamp"] as? String
        return annObj
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
    
    func loadAnnouncements() {
        if self.visibleViewController is RidgeIssuesVC {
            ActivityIndicator.shared.show(self.view)
            ridgeIssueRef.observe(DataEventType.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? NSDictionary {
                    let post = self.annInitialize(dictionary: dictionary)
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
    
    func createdAtInitialize(dictionary: NSDictionary) -> CreatedAt {
        let createdAt = CreatedAt()
        createdAt.date = dictionary["date"] as! Int
        createdAt.day = dictionary["day"] as! Int
        createdAt.hours = dictionary["hours"] as! Int
        createdAt.minutes = dictionary["minutes"] as! Int
        createdAt.month = dictionary["month"] as! Int
        createdAt.seconds = dictionary["seconds"] as! Int
        createdAt.time = dictionary["time"] as! Int
        createdAt.timezoneOffset = dictionary["timezoneOffset"] as! Int
        createdAt.year = dictionary["year"] as! Int
        return createdAt
    }
    
    func loadDataFromRealm() {
        if self.visibleViewController is RidgeIssuesVC {
            ridgeIssuesArr = ridgeIssueRealm.objects(RidgeIssues.self).sorted(byKeyPath: "timeStamp",ascending: false)
            DispatchQueue.main.async {
                ActivityIndicator.shared.hide()
                self.tableView.reloadData()
            }
        }
    }
    
}

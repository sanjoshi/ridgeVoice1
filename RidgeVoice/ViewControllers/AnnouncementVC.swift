//
//  AnnouncementVC.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 12/07/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class AnnouncementVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    lazy var announcementRef: DatabaseReference! = Database.database().reference().child("Announcements")
    var announcements: Results<Announcement>!
    let nsformatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        ActivityIndicator.shared.show(self.view)
        announcementRef.observe(DataEventType.value, with: { (snapshot) in
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
        self.title = "Announcements"
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
        if let addAnnVC = storyboard.instantiateViewController(withIdentifier: "postannvc") as? PostAnnouncementViewController {
            addAnnVC.isEdit = false
            addAnnVC.annDelegte = self
            addAnnVC.ObjDetails = nil
            self.present(addAnnVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = announcements {
            return announcements.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "announcementcell", for: indexPath) as? AnnouncementTableViewCell {
            cell.mainTxt.text = announcements[indexPath.row].message
            if let dateObj = announcements[indexPath.row].dateValue {
                cell.dateTxt.text = "Date: \(dateObj)"
            }
            return cell
        }
        return UITableViewCell()
    }
   
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addAnnVC = storyboard.instantiateViewController(withIdentifier: "postannvc") as? PostAnnouncementViewController {
                addAnnVC.isEdit = true
                addAnnVC.annDelegte = self
                addAnnVC.ObjDetails = self.announcements[indexPath.row]
                self.present(addAnnVC, animated: true, completion: nil)
            }
        }
        editAction.backgroundColor = Color.navigation.value
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            if let annId = self.announcements[indexPath.row].id {
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

extension AnnouncementVC: updateAnnoucementDelegate {
   func updateAnnoucementDelegate() {
        self.loadAnnouncements()
    }
    
    func annInitialize(dictionary: NSDictionary) -> Announcement {
        let annObj = Announcement()
        annObj.id = dictionary["id"] as? String
        if let dictObj = dictionary["user"] as? NSDictionary {
            annObj.user = userInitialize(dictionary: dictObj)
        }
        annObj.message = dictionary["message"] as? String
        if let datestr = dictionary["dateValue"] as? String {
            annObj.dateValue = datestr
        }
        annObj.timeStamp = dictionary["timeStamp"] as? String
        return annObj
    }
    
    func userInitialize(dictionary: NSDictionary) -> User {
        let user = User()
        user.id = dictionary["id"] as? String
        user.name = dictionary["name"] as? String
        user.email = dictionary["email"] as? String
        user.profilePictureURL = dictionary["profilePictureURL"] as? String
        return user
    }
    
    func loadAnnouncements() {
        if self.visibleViewController is AnnouncementVC {
            ActivityIndicator.shared.show(self.view)
            announcementRef.observe(DataEventType.childAdded, with: { (snapshot) in
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
        if self.visibleViewController is AnnouncementVC {
            announcements = annRealm.objects(Announcement.self).sorted(byKeyPath: "timeStamp",ascending: false)
            DispatchQueue.main.async {
                ActivityIndicator.shared.hide()
                self.tableView.reloadData()
            }
        }
    }
    
}

//
//  ServiceInfoViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 8/4/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class ServiceInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, serviceAddedDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var serviceRef: DatabaseReference! = Database.database().reference().child("Service")
    var serviceArr: Results<Service>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        ActivityIndicator.shared.show(self.view)
        serviceRef.observe(DataEventType.value, with: { (snapshot) in
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
        self.title = "Service Info"
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
        if let addAnnVC = storyboard.instantiateViewController(withIdentifier: "addservicevc") as? AddServiceViewController {
            addAnnVC.isEdit = false
            addAnnVC.serDelegte = self
            addAnnVC.ObjDetails = nil
            self.present(addAnnVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = serviceArr {
            return serviceArr.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "announcementcell", for: indexPath) as? AnnouncementTableViewCell {
            let formattedString = NSMutableAttributedString()
            if let msg = serviceArr[indexPath.row].name, !msg.isEmptyOrWhitespace() {
                let myAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
                let myString = NSMutableAttributedString(string: "\(msg) \n", attributes: myAttribute )
                formattedString.append(myString)
            }
            if let desc = serviceArr[indexPath.row].service, !desc.isEmptyOrWhitespace() {
                formattedString.normal(desc)
            }
            cell.mainTxt.attributedText = formattedString
            if let dateObj = serviceArr[indexPath.row].contact {
                cell.dateTxt.text = "\(dateObj)"
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addAnnVC = storyboard.instantiateViewController(withIdentifier: "addservicevc") as? AddServiceViewController {
                addAnnVC.isEdit = true
                addAnnVC.serDelegte = self
                addAnnVC.ObjDetails = self.serviceArr[indexPath.row]
                self.present(addAnnVC, animated: true, completion: nil)
            }
        }
        editAction.backgroundColor = Color.navigation.value
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            if let annId = self.serviceArr[indexPath.row].id {
                self.serviceRef.child(annId).removeValue()
                let annObj = serviceRealm.objects(Service.self).filter({ (annoucementObj) -> Bool in
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
extension ServiceInfoViewController {
    func serviceAddedDelegate() {
        self.loadAnnouncements()
    }
    
    func annInitialize(dictionary: NSDictionary) -> Service {
        let annObj = Service()
        annObj.id = dictionary["id"] as? String
        if let dictObj = dictionary["user"] as? NSDictionary {
            annObj.user = userInitialize(dictionary: dictObj)
        }
        annObj.name = dictionary["name"] as? String
        annObj.service = dictionary["service"] as? String
        annObj.contact = dictionary["contact"] as? String
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
        if self.visibleViewController is ServiceInfoViewController {
            ActivityIndicator.shared.show(self.view)
            serviceRef.observe(DataEventType.childAdded, with: { (snapshot) in
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
    
   func loadDataFromRealm() {
        if self.visibleViewController is ServiceInfoViewController {
            serviceArr = serviceRealm.objects(Service.self).sorted(byKeyPath: "name",ascending: false)
            DispatchQueue.main.async {
                ActivityIndicator.shared.hide()
                self.tableView.reloadData()
            }
        }
    }
    
}

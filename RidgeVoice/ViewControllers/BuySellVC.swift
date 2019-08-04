//
//  BuySellVC.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 12/07/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import RealmSwift

class BuySellVC: UIViewController , UITableViewDelegate, UITableViewDataSource, updateItemDelegate {
    lazy var sellItemRef: DatabaseReference! = Database.database().reference().child("SellItems")
    let loggedUser = Auth.auth().currentUser
    var items: Results<Item>!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        ActivityIndicator.shared.show(self.view)
        sellItemRef.observe(DataEventType.value, with: { (snapshot) in
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
        view.backgroundColor = Color.background.value
        self.title = "Items for Sale"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        let barButtonItem = UIBarButtonItem(title: "Post Item", style: .plain, target: self, action: #selector(addTapped))
        barButtonItem.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 17)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .normal)
        navigationItem.rightBarButtonItem = barButtonItem
        
        self.tableView.reloadData()
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addItemVC = storyboard.instantiateViewController(withIdentifier: "additemvc") as? AddItemViewController {
            addItemVC.isEdit = false
            addItemVC.itemDelegte = self
            addItemVC.ObjDetails = nil
            self.present(addItemVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = items {
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "profilecellidentifier", for: indexPath) as? ProfileTableViewCell {
            let str = "\(items[indexPath.row].itemName ?? "")\n\(items[indexPath.row].itemPrice ?? "")"
            cell.profileTxt.text = str
            if let picURL = items[indexPath.row].itemImage1 {
                cell.profileImg.sd_setImage(with: URL(string: picURL), placeholderImage: UIImage(named: "placeholderImage"))
            } else {
                cell.profileImg.image = UIImage(named: "placeholderImage")
            }
            cell.profileImg.roundedImage()
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addItemVC = storyboard.instantiateViewController(withIdentifier: "additemvc") as? AddItemViewController {
                addItemVC.isEdit = true
                addItemVC.itemDelegte = self
                addItemVC.ObjDetails = self.items[indexPath.row]
                self.present(addItemVC, animated: true, completion: nil)
            }
        }
        editAction.backgroundColor = Color.navigation.value
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            if let annId = self.items[indexPath.row].id {
                self.sellItemRef.child(annId).removeValue()
                let annObj = saleItemRealm.objects(Item.self).filter({ (annoucementObj) -> Bool in
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
        return [editAction, deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let userObj = items[indexPath.row].user, let userId = userObj.id, loggedUser?.uid == userId {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let ItemVC = storyboard.instantiateViewController(withIdentifier: "itemdetailvc") as? ItemDetailsViewController {
            ItemVC.ObjDetails = self.items[indexPath.row]
            self.present(ItemVC, animated: true, completion: nil)
        }
    }
}

extension BuySellVC {
    func updateItemDelegate() {
        self.loadAnnouncements()
    }
    
    func annInitialize(dictionary: NSDictionary) -> Item {
        let itemObj = Item()
        itemObj.id = dictionary["id"] as? String
        if let dictObj = dictionary["user"] as? NSDictionary {
            itemObj.user = userInitialize(dictionary: dictObj)
        }
        itemObj.itemName = dictionary["itemName"] as? String
        itemObj.itemDesc = dictionary["itemDesc"] as? String
        itemObj.itemPrice = dictionary["itemPrice"] as? String
        itemObj.itemImage1 = dictionary["itemImage1"] as? String
        itemObj.itemImage2 = dictionary["itemImage2"] as? String
        itemObj.contactDetails = dictionary["contactDetails"] as? String
        return itemObj
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
        if self.visibleViewController is BuySellVC {
            ActivityIndicator.shared.show(self.view)
            sellItemRef.observe(DataEventType.childAdded, with: { (snapshot) in
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
        if self.visibleViewController is BuySellVC {
            items = saleItemRealm.objects(Item.self).sorted(byKeyPath: "itemName",ascending: true)
            DispatchQueue.main.async {
                ActivityIndicator.shared.hide()
                self.tableView.reloadData()
            }
        }
    }
    
}

//
//  ViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/9/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase

class DashBoardVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    var titles=["Profile","Board Members","Buy/Sell Items","Announcement","Ridge Issues","Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.background.value
        self.title = "Home"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        self.navigationController!.navigationBar.tintColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    // MARK: UICollectionView Delegate & Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return titles.count
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CollectionViewCell=collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor(hexString: "#1F618D")
        cell.cellTitle.text = titles[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        case 1:
            if let boardmemVC = self.storyboard?.instantiateViewController(withIdentifier: "BoardMembersVC") as? BoardMembersVC {
                self.navigationController?.pushViewController(boardmemVC, animated: true)
            }
        case 2:
            if let buysellVC = self.storyboard?.instantiateViewController(withIdentifier: "BuySellVC") as? BuySellVC {
                self.navigationController?.pushViewController(buysellVC, animated: true)
            }
        case 3:
            if let announcementVC = self.storyboard?.instantiateViewController(withIdentifier: "AnnouncementVC") as? AnnouncementVC {
                self.navigationController?.pushViewController(announcementVC, animated: true)
            }
        case 4:
            if let ridgeissueVC = self.storyboard?.instantiateViewController(withIdentifier: "RidgeIssuesVC") as? RidgeIssuesVC {
                self.navigationController?.pushViewController(ridgeissueVC, animated: true)
            }
        case 5:
            do {
                try Auth.auth().signOut()
                if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginvc") as? LoginViewController {
                    UserDefaults.standard.set(nil, forKey: "userLoggedIn")
                    UserDefaults.standard.synchronize()
                    let navigationController = UINavigationController(rootViewController: loginVC)
                    navigationController.isNavigationBarHidden = true
                    UIApplication.shared.keyWindow?.rootViewController = navigationController
                }
            } catch let err {
                print(err)
            }            
        default:
            if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
    }

}


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
    
    var titles=["Profiles","Board Members","Sell Items","Announcements","Ridge Issues","Service Info"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        self.title = "Home"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        let barButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(Logout))
        barButtonItem.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 17)!,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .normal)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func Logout(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginvc") as? LoginViewController {
                UserDefaults.standard.set(nil, forKey: "userLoggedIn")
                UserDefaults.standard.set(nil, forKey: "isAdmin")
                UserDefaults.standard.synchronize()
                let navigationController = UINavigationController(rootViewController: loginVC)
                navigationController.isNavigationBarHidden = true
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navigationController
            }
        } catch let err {
            print(err)
        }
    }
    
    // MARK: UICollectionView Delegate & Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CollectionViewCell=collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = Color.button.value
        cell.cellTitle.text = titles[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
                profileVC.shouldShowMyProfile = true
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        case 1:
            if let boardmemVC = self.storyboard?.instantiateViewController(withIdentifier: "BoardMembersVC") as? BoardMembersVC {
                self.navigationController?.pushViewController(boardmemVC, animated: true)
            }
        case 2:
             break
//            if let buysellVC = self.storyboard?.instantiateViewController(withIdentifier: "BuySellVC") as? BuySellVC {
//                self.navigationController?.pushViewController(buysellVC, animated: true)
//            }
        case 3:
            if let announcementVC = self.storyboard?.instantiateViewController(withIdentifier: "AnnouncementVC") as? AnnouncementVC {
                self.navigationController?.pushViewController(announcementVC, animated: true)
            }
        case 4:
             break
//            if let ridgeissueVC = self.storyboard?.instantiateViewController(withIdentifier: "RidgeIssuesVC") as? RidgeIssuesVC {
//                self.navigationController?.pushViewController(ridgeissueVC, animated: true)
//            }
        default:
            break
        }
    }

}


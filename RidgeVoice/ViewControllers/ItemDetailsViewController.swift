//
//  ItemDetailsViewController.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 8/4/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit
import Firebase

class ItemDetailsViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var buttonConstarint: NSLayoutConstraint!
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var contactNo: UITextField!
    var ObjDetails: Item?
    lazy var sellItemRef: DatabaseReference! = Database.database().reference().child("SellItems")

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        view.backgroundColor = Color.background.value
        txtView.isEditable = false
        nameText.setLeftPaddingPoints(10)
        priceText.setLeftPaddingPoints(10)
        contactNo.setLeftPaddingPoints(10)
        if let messageObj = ObjDetails {
            txtView.text = messageObj.itemDesc
            nameText.text = messageObj.itemName
            priceText.text = messageObj.itemPrice
            contactNo.text = messageObj.contactDetails
            if let picURL1 = messageObj.itemImage1 {
                imgView1.sd_setImage(with: URL(string: picURL1), placeholderImage: UIImage(named: "placeholderImage"))
            } else {
                imgView1.image = UIImage(named: "placeholderImage")
            }
            if let picURL2 = messageObj.itemImage2 {
                imgView2.sd_setImage(with: URL(string: picURL2), placeholderImage: UIImage(named: "placeholderImage"))
            } else {
                imgView2.image = UIImage(named: "placeholderImage")
            }
            textViewFrame()
        }
    }
    
    func textViewFrame() {
        let fixedWidth = txtView.frame.size.width
        txtView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = txtView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = txtView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        txtView.frame = newFrame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UIDevice.current.orientation.isLandscape {
            if UIDevice.current.hasNotch {
                buttonConstarint.constant = self.view.frame.width/2 + 100
            } else {
                buttonConstarint.constant = self.view.frame.width/2 + 50
            }
        } else {
            buttonConstarint.constant = 84
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            if UIDevice.current.hasNotch {
                buttonConstarint.constant = self.view.frame.width/2 + 100
            } else {
                buttonConstarint.constant = self.view.frame.width/2 + 50
            }
        } else {
            buttonConstarint.constant = 84
        }
    }

    @IBAction func callAction(_ sender: UIButton) {
        if let contactNo = ObjDetails?.contactDetails, let url = URL(string: "tel://\(contactNo)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            var contentRect = CGRect.zero
            for view in self.scrollView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            if UIDevice.current.orientation.isLandscape {
                self.scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height + 250)
            } else {
                self.scrollView.contentSize = CGSize(width: contentRect.size.width, height: contentRect.size.height + 10)
            }
        }
    }
}

//
//  ProfileTableViewCell.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/23/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var profileTxt: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

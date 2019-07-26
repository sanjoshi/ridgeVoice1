//
//  BoardTableViewCell.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/12/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit

class BoardTableViewCell: UITableViewCell {
    @IBOutlet weak var nameTxt: UILabel!
    @IBOutlet weak var positionTxt: UILabel!
    @IBOutlet weak var contactTxt: UILabel!
    @IBOutlet weak var emailTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

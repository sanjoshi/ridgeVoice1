//
//  AnnouncementTableViewCell.swift
//  RidgeVoice
//
//  Created by Amit Mathur on 7/14/19.
//  Copyright © 2019 Amit Mathur. All rights reserved.
//

import UIKit

class AnnouncementTableViewCell: UITableViewCell {
    @IBOutlet weak var mainTxt: UILabel!
    @IBOutlet weak var dateTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

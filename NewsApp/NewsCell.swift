//
//  NewsCell.swift
//  NewsApp
//
//  Created by Wei Liang Tan on 15/6/19.
//  Copyright © 2019 Wei Liang Tan. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var detailLabel: UILabel?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

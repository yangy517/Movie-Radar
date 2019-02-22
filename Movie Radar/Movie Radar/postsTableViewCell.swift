//
//  postsTableViewCell.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/6/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit

class postsTableViewCell: UITableViewCell {

    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet var ratingStars: [UIImageView]!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

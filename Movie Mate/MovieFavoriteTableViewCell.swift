//
//  MovieFavoriteTableViewCell.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 25.12.2024.
//

import UIKit

class MovieFavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieIdLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

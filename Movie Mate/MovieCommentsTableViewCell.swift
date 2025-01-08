//
//  MovieCommentsTableViewCell.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 30.12.2024.
//

import UIKit

class MovieCommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  

}

//
//  EditTableViewCell.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 8.01.2025.
//

import UIKit

class EditTableViewCell: UITableViewCell {

    @IBOutlet weak var EditLabel: UILabel!
    @IBOutlet weak var editLabelId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  MovieFeedCollectionViewCollectionViewCell.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 13.12.2024.
//

import UIKit

class MovieFeedCollectionViewCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var movieImage: UIImageView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           setupCell()
       }
       
//       private func setupCell() {
//           // Köşe yarıçapını ayarla
//           self.contentView.layer.cornerRadius = 10.0
//           self.contentView.layer.masksToBounds = true // Köşe taşmasını önler
//       }
    
    private func setupCell() {
           // Gölge için ayarlar
           self.layer.shadowColor = UIColor.black.cgColor
           self.layer.shadowOpacity = 0.2
           self.layer.shadowOffset = CGSize(width: 2, height: 2)
           self.layer.shadowRadius = 4.0
        self.contentView.backgroundColor = UIColor.lightGray // Arka plan rengini gri yap

           
           // Köşe yarıçapı
           self.contentView.layer.cornerRadius = 10.0
           self.contentView.layer.masksToBounds = true
       }
    
}

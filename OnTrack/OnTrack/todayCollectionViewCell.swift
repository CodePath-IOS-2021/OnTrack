//
//  todayCollectionViewCell.swift
//  OnTrack
//
//  Created by Sophia Lui on 5/19/21.
//

import UIKit

class todayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dish1NameLabel: UILabel!
    @IBOutlet weak var dish1CalorieLabel: UILabel!
    
    @IBOutlet weak var dish2NameLabel: UILabel!
    @IBOutlet weak var dish2CalorieLabel: UILabel!
    
    @IBOutlet weak var dish3NameLabel: UILabel!
    @IBOutlet weak var dish3CalorieLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Apply rounded corners
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
                
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = 5.0
        layer.masksToBounds = false
    }

}

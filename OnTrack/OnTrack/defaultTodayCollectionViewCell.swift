//
//  defaultTodayCollectionViewCell.swift
//  OnTrack
//
//  Created by Meshach Adoe on 29/05/21.
//

import UIKit

class defaultTodayCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Apply rounded corners
        contentView.layer.cornerRadius = 12.0
        contentView.layer.masksToBounds = true
                
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = 12.0
        layer.masksToBounds = false
    }
}

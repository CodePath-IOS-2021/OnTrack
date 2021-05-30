//
//  defaultTodayCollectionViewCell.swift
//  OnTrack
//
//  Created by Meshach Adoe on 29/05/21.
//

import UIKit

class defaultTodayCollectionViewCell: UICollectionViewCell {
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

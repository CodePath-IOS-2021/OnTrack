//
//  DateCollectionViewCell.swift
//  OnTrack
//
//  Created by  caijicang on 2021/6/7.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayOfWeek: UILabel!
    @IBOutlet weak var dateOfMonth: UILabel!
    @IBOutlet weak var dateOfMonthBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Apply rounded corners
        contentView.layer.cornerRadius = 25
        
        dateOfMonthBackground.layer.cornerRadius = 20
    }
    
}

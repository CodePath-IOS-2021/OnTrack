//
//  profileMealsTableViewCell.swift
//  OnTrack
//
//  Created by Sophia Lui on 5/19/21.
//

import UIKit

class profileMealsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeCreatedLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var mealLabel: UILabel!
    
    @IBOutlet weak var border: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        mealImageView.layer.cornerRadius = 10.0
        border.layer.cornerRadius = 15.0
        border.layer.borderWidth = 2
        border.layer.borderColor = UIColor.systemGray4.cgColor
    }

}

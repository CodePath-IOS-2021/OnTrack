//
//  MealPlanTableViewCell.swift
//  OnTrack
//
//  Created by  caijicang on 2021/6/8.
//

import UIKit

class MealPlanTableViewCell: UITableViewCell {

    @IBOutlet weak var meal_image: UIImageView!
    @IBOutlet weak var meal_label: UILabel!
    @IBOutlet weak var meal_calories: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        meal_image.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

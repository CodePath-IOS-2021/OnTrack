//
//  communityTableViewCell.swift
//  OnTrack
//
//  Created by Sophia Lui on 5/19/21.
//

import UIKit

class communityTableViewCell: UITableViewCell {

    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}

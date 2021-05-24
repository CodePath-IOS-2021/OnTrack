//
//  HomeViewController.swift
//  OnTrack
//
//  Created by Sophia Lui on 5/19/21.
//

import UIKit
import Parse

class HomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var todayCollectionViewCell: UICollectionViewCell!
    @IBOutlet weak var communityTableView: UITableView!
    
    var allMealPlan = [PFObject]()
    var myMealPlan = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communityTableView.dataSource = self
        communityTableView.delegate = self
        
       /* todayCollectionViewCell.delegate = self
        todayCollectionViewCell.dataSource = self*/

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let query = PFQuery(className: "MealPlan")
        query.includeKeys(["user", "createdAt", "breakfast_recipes"])
        query.limit = 20
        
        query.findObjectsInBackground { allMealPlan, error in
            if allMealPlan != nil {
                self.allMealPlan = allMealPlan!
                self.communityTableView.reloadData()
            }
        }
    }
    
    // NOTE: IMAGE SHOULD BE STORED IN BACK4APP, SO WE CAN ACCESS IT THROUGH THE CURRENT USER, IMAGE SHOULD BE APART OF IT, AFTER THEY ADDED IT IN RECIPEVIEWCONTROLLER
    
    // TABLE VIEW: For community posts
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMealPlan.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mealPlan = allMealPlan[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "communityTableViewCell") as! communityTableViewCell
        
        let user = mealPlan["user"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.createdLabel.text = mealPlan["createdAt"] as? String ?? "12:00pm"
        
        let breakfastMeals = (mealPlan["breakfast_recipes"] as? [PFObject]) ?? []
        cell.mealLabel.text = breakfastMeals[0]["label"] as! String
        cell.calorieLabel.text = breakfastMeals[0]["calories"] as! String
        
        let mealURL = URL(string :"https://www.closetcooking.com/wp-content/uploads/2018/03/TonkotsuRamen8000837-min.jpg");
        cell.mealImageView.af_setImage(withURL: mealURL!)
        
        return cell 

    }
    
    // COLLECTION VIEW: For today's planned meals cards
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCollectionViewCell", for: indexPath) as! todayCollectionViewCell
        
        return cell
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

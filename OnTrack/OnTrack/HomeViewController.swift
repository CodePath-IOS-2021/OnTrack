//
//  HomeViewController.swift
//  OnTrack
//
//  Created by Sophia Lui on 5/19/21.
//

import UIKit
import Parse

class HomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var todayCollectionView: UICollectionView!
    @IBOutlet weak var communityTableView: UITableView!
    
    var allMealPlan = [PFObject]()
    var myMealPlan = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communityTableView.dataSource = self
        communityTableView.delegate = self
        
        
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let query = PFQuery(className: "MealPlan")
        query.includeKeys(["objectId", "user", "createdAt", "breakfast_recipes", "lunch_recipes", "dinner_recipes"])
        query.limit = 20
        
        query.findObjectsInBackground { allMealPlan, error in
            if allMealPlan != nil {
                self.allMealPlan = allMealPlan!
                self.allMealPlan.reverse()
                self.communityTableView.reloadData()
                self.todayCollectionView.reloadData()
            }
        }
        
        let user = PFUser.current()!
        if (user["meal_plans"] != nil) {
            let userPlans = user["meal_plans"] as! [PFObject]
            let currPlanObj = userPlans[(userPlans.count - 1)]
            myMealPlan = currPlanObj.objectId!
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
        
        var meals = [PFObject]()
        switch Int.random(in: 0...2) {
        case 0:
            meals = (mealPlan["breakfast_recipes"] as? [PFObject]) ?? []
        case 1:
            meals = (mealPlan["lunch_recipes"] as? [PFObject]) ?? []
        default:
            meals = (mealPlan["dinner_recipes"] as? [PFObject]) ?? []
        }
        if (meals.count == 0) {
            return cell
        }
        
        let date = mealPlan.createdAt!
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        cell.createdLabel.text = formatter.string(from: date)
        cell.mealLabel.text = (meals[0]["label"] as! String)
        cell.calorieLabel.text = (meals[0]["calories"] as! String)
        
        let mealURL = URL(string: meals[0]["image"] as! String);
        cell.mealImageView.af_setImage(withURL: mealURL!)
        
        return cell

    }
    
    // COLLECTION VIEW: For today's planned meals cards
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if myMealPlan != "" {
            return 3
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if myMealPlan != "" {
            for plan in allMealPlan {
                let planId = plan.objectId!
                if planId != myMealPlan {
                    continue
                }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCollectionViewCell", for: indexPath) as! todayCollectionViewCell
                
                var meals = [PFObject]()
                if indexPath.row == 0 {
                    meals = (plan["breakfast_recipes"] as? [PFObject]) ?? []
                    cell.mealTypeLabel.text = "Breakfast"
                } else if indexPath.row == 1 {
                    meals = (plan["lunch_recipes"] as? [PFObject]) ?? []
                    cell.mealTypeLabel.text = "Lunch"
                } else if indexPath.row == 2 {
                    meals = (plan["dinner_recipes"] as? [PFObject]) ?? []
                    cell.mealTypeLabel.text = "Dinner"
                }
                
                if (meals.count >= 1) {
                    cell.dish1NameLabel.text = meals[0]["label"] as? String
                    cell.dish1CalorieLabel.text = meals[0]["calories"] as? String
                } else {
                    cell.dish1NameLabel.text = ""
                    cell.dish1CalorieLabel.text = ""
                }
                if (meals.count >= 2) {
                    cell.dish2NameLabel.text = meals[1]["label"] as? String
                    cell.dish2CalorieLabel.text = meals[1]["calories"] as? String
                } else {
                    cell.dish2NameLabel.text = ""
                    cell.dish2CalorieLabel.text = ""
                }
//                if (meals.count >= 3) {
//                    cell.dish3NameLabel.text = meals[2]["label"] as? String
//                    cell.dish3CalorieLabel.text = meals[2]["calories"] as? String
//                } else {
                cell.dish3NameLabel.text = ""
                cell.dish3CalorieLabel.text = ""
//                }
                
                return cell
            }
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultTodayCollectionViewCell", for: indexPath) as! defaultTodayCollectionViewCell
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

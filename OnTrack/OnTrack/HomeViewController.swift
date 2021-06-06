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
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communityTableView.dataSource = self
        communityTableView.delegate = self
        communityTableView.separatorStyle = UITableViewCell.SeparatorStyle.none     // remove separator
        
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(loadMealPlans), for: .valueChanged)  // "self" means the current screen
        communityTableView.refreshControl = myRefreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadMealPlans()
    }
    
    @objc func loadMealPlans() {
        let query = PFQuery(className: "MealPlan")
        query.includeKeys(["objectId", "user", "createdAt", "breakfast_recipes", "lunch_recipes", "dinner_recipes"])
        query.limit = 20
        
        query.findObjectsInBackground { allMealPlan, error in
            if allMealPlan != nil {
                self.allMealPlan = allMealPlan!
                self.allMealPlan.reverse()
                self.communityTableView.reloadData()
                self.todayCollectionView.reloadData()
                self.myRefreshControl.endRefreshing()   // end refreshing after pulling, otherwise the spin will be there forever
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
    
    // MARK: Community Post TABLE VIEW
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
        cell.mealImageView.af.setImage(withURL: mealURL!)
        
        return cell

    }
    
    // MARK: Today's mealplan COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // if the current user doesn't have any meal plan, display three empty widgets
        if myMealPlan == "" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultTodayCollectionViewCell", for: indexPath) as! defaultTodayCollectionViewCell
            if indexPath.row == 0 {
                cell.backgroundColor = UIColor(red: 0.89, green: 0.21, blue: 0.21, alpha: 0.63)
                cell.label.text = "No meals planned for breakfast"
            } else if indexPath.row == 1 {
                cell.backgroundColor = UIColor(red: 0.17, green: 0.76, blue: 0.19, alpha: 0.90)
                cell.label.text = "No meals planned for lunch"
            } else if indexPath.row == 2 {
                cell.backgroundColor = UIColor(red: 0, green: 0.58, blue: 1, alpha: 1)
                cell.label.text = "No meals planned for dinner"
            }
            return cell
        }
        
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
                    cell.backgroundColor = UIColor(red: 0.89, green: 0.21, blue: 0.21, alpha: 0.63)
                } else if indexPath.row == 1 {
                    meals = (plan["lunch_recipes"] as? [PFObject]) ?? []
                    cell.mealTypeLabel.text = "Lunch"
                    cell.backgroundColor = UIColor(red: 0.17, green: 0.76, blue: 0.19, alpha: 0.90)
                } else if indexPath.row == 2 {
                    meals = (plan["dinner_recipes"] as? [PFObject]) ?? []
                    cell.mealTypeLabel.text = "Dinner"
                    cell.backgroundColor = UIColor(red: 0, green: 0.58, blue: 1, alpha: 1)
                }
                
                // if the meal count is 0, display an empty widge
                if meals.count == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultTodayCollectionViewCell", for: indexPath) as! defaultTodayCollectionViewCell
                    if indexPath.row == 0 {
                        cell.backgroundColor = UIColor(red: 0.89, green: 0.21, blue: 0.21, alpha: 0.63)
                        cell.label.text = "No meals planned for breakfast"
                    } else if indexPath.row == 1 {
                        cell.backgroundColor = UIColor(red: 0.17, green: 0.76, blue: 0.19, alpha: 0.90)
                        cell.label.text = "No meals planned for lunch"
                    } else if indexPath.row == 2 {
                        cell.backgroundColor = UIColor(red: 0, green: 0.58, blue: 1, alpha: 1)
                        cell.label.text = "No meals planned for dinner"
                    }
                    return cell
                }
                
                if (meals.count >= 1) {
                    cell.dish1NameLabel.text = meals[0]["label"] as? String
                    cell.dish1CalorieLabel.text = meals[0]["calories"] as? String
                }
                
                if (meals.count >= 2) {
                    cell.dish2NameLabel.text = meals[1]["label"] as? String
                    cell.dish2CalorieLabel.text = meals[1]["calories"] as? String
                } else {
                    cell.dish2NameLabel.text = ""
                    cell.dish2CalorieLabel.text = ""
                    cell.meal2.backgroundColor = UIColor.clear
                }
                if (meals.count >= 3) {
                    cell.dish3NameLabel.text = meals[2]["label"] as? String
                    cell.dish3CalorieLabel.text = meals[2]["calories"] as? String
                } else {
                    cell.dish3NameLabel.text = ""
                    cell.dish3CalorieLabel.text = ""
                    cell.meal3.backgroundColor = UIColor.clear
                }
                
                return cell
            }
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultTodayCollectionViewCell", for: indexPath) as! defaultTodayCollectionViewCell
        return cell
    }
    
    
    // MARK: - Navigation
    @IBAction func onLogoutBtn(_ sender: Any) {
        PFUser.logOut()     // clear the parse cache
        // navigate back to the login screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "loginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController = loginViewController
    }
    
    

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

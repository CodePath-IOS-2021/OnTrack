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
    
    var allMealPlan = [PFObject]()      // store all meal plans in the database for community posts
    var myTodayMealPlan: PFObject?     // store current user's today's meal plan for today's meal section
    
    // utils
    let dateFormatter = DateFormatter()
    let dayOfWeekFormatter = DateFormatter()
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communityTableView.dataSource = self
        communityTableView.delegate = self
        communityTableView.separatorStyle = UITableViewCell.SeparatorStyle.none     // remove separator
        communityTableView.allowsSelection = false
        
        todayCollectionView.delegate = self
        todayCollectionView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(loadMealPlans), for: .valueChanged)  // "self" means the current screen
        communityTableView.refreshControl = myRefreshControl
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dayOfWeekFormatter.dateFormat = "EEEE"      // "Monday"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadMealPlans()
    }
    
    // MARK: Databse Request
    
    // load in all meal plans in the database for community post
    // load in all current user's meal plans for today's meal section and deleting outdated plan
    @objc func loadMealPlans() {
        let query = PFQuery(className: "MealPlan")
        query.includeKeys(["objectId", "user", "createdAt", "breakfast_recipes", "lunch_recipes", "dinner_recipes"])
        query.limit = 20
        
        // fetch all meal plans in the database
        query.findObjectsInBackground { allMealPlan, error in
            if allMealPlan != nil {
                self.allMealPlan = allMealPlan!
                self.allMealPlan.reverse()
                self.communityTableView.reloadData()
                self.myRefreshControl.endRefreshing()   // end refreshing after pulling, otherwise the spin will be there forever
                
                // fetch all meal plans from the current user
                // can only execute a new query after the first fetch finishes
                if let currentUser = PFUser.current() {
                    query.whereKey("user", equalTo: currentUser)
                    query.findObjectsInBackground { currentUserMealPlans, Error in
                        if currentUserMealPlans != nil {
                            // find current user's today's meal plan
                            let today = Date()
                            let todayDate = self.dateFormatter.string(from: today)
                            
                            self.myTodayMealPlan = nil
                            for plan in currentUserMealPlans! {
                                let curr_date = self.dateFormatter.date(from: plan["date"] as! String)!
                                
                                if plan["date"] as! String == todayDate {
                                    self.myTodayMealPlan = plan
                                }
                                // if curr_plan is outdated, delete it in the database
                                else if curr_date < today {
                                    // delete all recipe objects and the meal plan object
                                    for recipe in plan["breakfast_recipes"] as! [PFObject] {
                                        recipe.deleteInBackground()
                                    }
                                    for recipe in plan["lunch_recipes"] as! [PFObject] {
                                        recipe.deleteInBackground()
                                    }
                                    for recipe in plan["dinner_recipes"] as! [PFObject] {
                                        recipe.deleteInBackground()
                                    }
                                    var new_mealPlan = [PFObject]()
                                    for curr_plan in currentUser["meal_plans"] as! [PFObject] {
                                        if curr_plan.objectId != plan.objectId {
                                            new_mealPlan.append(curr_plan)
                                        }
                                    }
                                    // reset the "meal_plans" attribute of the current user
                                    currentUser["meal_plans"] = new_mealPlan
                                    currentUser.saveInBackground(block: { success, error in
                                        if success {
                                            print("User profile updated")
                                            plan.deleteInBackground(block: { success, error in
                                                if success {
                                                    print("outdated meal plan deleted")
                                                } else {
                                                    print(error!)
                                                }
                                            })
                                        } else {
                                            print(error!)
                                        }
                                    })
                                }
                            }
                        }
                        self.todayCollectionView.reloadData()
                    }
                }
            }
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
        var mealType = ""
        // randomized post
        while(meals.count == 0){
            switch Int.random(in: 0...2) {
            case 0:
                meals = (mealPlan["breakfast_recipes"] as? [PFObject]) ?? []
                mealType = "breakfast"
            case 1:
                meals = (mealPlan["lunch_recipes"] as? [PFObject]) ?? []
                mealType = "lunch"
            default:
                meals = (mealPlan["dinner_recipes"] as? [PFObject]) ?? []
                mealType = "dinner"
            }
        }
        
        let date = mealPlan.createdAt!
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        cell.createdLabel.text = formatter.string(from: date)
        
        let randomIndex = Int.random(in: 0..<meals.count)
        
        cell.mealLabel.text = (meals[randomIndex]["label"] as! String)
        cell.calorieLabel.text = (meals[randomIndex]["calories"] as! String)
        cell.mealTypeLabel.text = mealType
        
        let mealURL = URL(string: meals[randomIndex]["image"] as! String);
        cell.mealImageView.af.setImage(withURL: mealURL!)
        
        let mealPlan_date = dateFormatter.date(from: mealPlan["date"] as! String)!
        let dayOfWeekString = dayOfWeekFormatter.string(from: mealPlan_date)
        cell.dayOfWeek.text = dayOfWeekString
        
        return cell

    }
    
    // MARK: Today's mealplan COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // if there is no meal planned for today, display three empty widgets
        if self.myTodayMealPlan == nil {
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
        
        // fetch the meals for one of breakfast, lunch, dinner
        var meals = [PFObject]()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCollectionViewCell", for: indexPath) as! todayCollectionViewCell
        if indexPath.row == 0 {
            meals = myTodayMealPlan?["breakfast_recipes"] as! [PFObject]
            cell.mealTypeLabel.text = "Breakfast"
            cell.backgroundColor = UIColor(red: 0.89, green: 0.21, blue: 0.21, alpha: 0.63)
        } else if indexPath.row == 1 {
            meals = myTodayMealPlan?["lunch_recipes"] as! [PFObject]
            cell.mealTypeLabel.text = "Lunch"
            cell.backgroundColor = UIColor(red: 0.17, green: 0.76, blue: 0.19, alpha: 0.90)
        } else if indexPath.row == 2 {
            meals = myTodayMealPlan?["dinner_recipes"] as! [PFObject]
            cell.mealTypeLabel.text = "Dinner"
            cell.backgroundColor = UIColor(red: 0, green: 0.58, blue: 1, alpha: 1)
        }
        
        // if there is no meal planned, display empty widgets
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
            cell.meal2.backgroundColor = UIColor.white
        } else {
            cell.dish2NameLabel.text = ""
            cell.dish2CalorieLabel.text = ""
            cell.meal2.backgroundColor = UIColor.clear
        }
        if (meals.count >= 3) {
            cell.dish3NameLabel.text = meals[2]["label"] as? String
            cell.dish3CalorieLabel.text = meals[2]["calories"] as? String
            cell.meal3.backgroundColor = UIColor.white
        } else {
            cell.dish3NameLabel.text = ""
            cell.dish3CalorieLabel.text = ""
            cell.meal3.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    
    // MARK: - Logout
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

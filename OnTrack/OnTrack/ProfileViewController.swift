//
//  ProfileViewController.swift
//  OnTrack
//
//  Created by Sophia Lui on 5/19/21.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var allMealPlan = [PFObject]()
    var currentID = ""
    
    // Storing only the current user's meals
    var myMeals = [PFObject]();


    @IBOutlet weak var mealsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealsTableView.delegate = self
        mealsTableView.dataSource = self
        mealsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none     // remove separator

    }
    override func viewDidAppear(_ animated: Bool) {
        // refresh again
        super.viewDidAppear(animated)
        myMeals = [PFObject]()
        self.loadMealPlans()
        
 
    }
    
    @objc func loadMealPlans() {
        
        let query = PFQuery(className: "MealPlan")
        query.includeKeys(["objectId", "user", "createdAt", "breakfast_recipes", "lunch_recipes", "dinner_recipes"])
        query.limit = 20
        
        query.findObjectsInBackground { allMealPlan, error in
            if allMealPlan != nil {
                // stored all of the recipes basically... in allMealPlan
                self.allMealPlan = allMealPlan!

                let user = PFUser.current()!
                if(user["meal_plans"] != nil){
                    
                    let userPlans = user["meal_plans"] as! [PFObject]
                    for currentMeals in userPlans{
                        
                        // getting the current meal's objID
                        self.currentID =  currentMeals.objectId!
                        
                        for meals in self.allMealPlan{
                            if self.currentID == meals.objectId{
                                self.myMeals.append(meals)
                            }
                        }
                        
                    }
                    self.mealsTableView.reloadData()
                }
                                     
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myMeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileMealsTableViewCell") as! profileMealsTableViewCell
        let mealPlan = self.myMeals[indexPath.row]

        cell.usernameLabel.text = PFUser.current()!.username! as String;

        var meals = [PFObject]()

        while(meals.count == 0){
            switch Int.random(in: 0...2) {
            case 0:
                meals = (mealPlan["breakfast_recipes"] as? [PFObject]) ?? []
            case 1:
                meals = (mealPlan["lunch_recipes"] as? [PFObject]) ?? []
            default:
                meals = (mealPlan["dinner_recipes"] as? [PFObject]) ?? []
            }
            
        }
        
        let date = mealPlan.createdAt!
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        cell.timeCreatedLabel.text = formatter.string(from: date)
        cell.mealLabel.text = (meals[0]["label"] as! String)
        cell.caloriesLabel.text = (meals[0]["calories"] as! String)
    
        let mealURL = URL(string: meals[0]["image"] as! String);
        cell.mealImageView.af.setImage(withURL: mealURL!)
    
        return cell
    
    }
    

}

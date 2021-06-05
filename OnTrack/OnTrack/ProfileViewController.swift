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
                print("user[meal]:" , user["meal_plans"])
                
                if(user["meal_plans"] != nil){
                    
                    let userPlans = user["meal_plans"] as! [PFObject]
                    var userNumPlans = userPlans.count - 1;
                 //   let currentPlanObj = userPlans[(userPlans.count-1)]
                    //self.currentID = currentPlanObj.objectId!
                    print("HELLO")
                    // this is used to retrieve the actual recipes
                    
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
    
            // isolating the current user's meal plans
           /* let user = PFUser.current()!
            if(user["meal_plans"] != nil){
                
                let userPlans = user["meal_plans"] as! [PFObject]
                var userNumPlans = userPlans.count - 1;
             //   let currentPlanObj = userPlans[(userPlans.count-1)]
                //self.currentID = currentPlanObj.objectId!
                
                // this is used to retrieve the actual recipes
                for meals in self.allMealPlan{
                    
                    if(userNumPlans == 0){
                        break
                    }
                    let currentPlanObj = userPlans[userNumPlans]
                    print(currentPlanObj)
                    self.currentID = currentPlanObj.objectId!
                    
                    
                    // storing only the current user's meals
                    print(self.currentID)
                    if self.currentID == meals.objectId{
                        self.myMeals.append(meals)
                        print("printing myMeals in IF loadMeals()")
                        print(self.myMeals)

                    }
                    userNumPlans = userNumPlans - 1;
                    print("printing myMeals in loadMeals()")
                    print(self.myMeals)
                }
            }
            //print("printing myMeals in loadMeals()")
            //print(self.myMeals)

            
        }
 
    }*/
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myMeals.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileMealsTableViewCell") as! profileMealsTableViewCell
        let mealPlan = self.myMeals[indexPath.row]
        print("printing mealPlan from table view: ")
        print(mealPlan)
        cell.usernameLabel.text = PFUser.current()!.username! as String;



        /*print("CHCEKNG IN TABLEVIEW WITH MEALPLAN")
        let mealPlan = self.posts[indexPath.row]
        
        print()
        // USERNAME
        //let username = PFUser.current()!.username! as String
        cell.usernameLabel.text = PFUser.current()!.username! as String;
        */
        var meals = [PFObject]()
      /*  switch Int.random(in: 0...2) {
        case 0:
            meals = (mealPlan["breakfast_recipes"] as? [PFObject]) ?? []
        case 1:
            meals = (mealPlan["lunch_recipes"] as? [PFObject]) ?? []
        default:
            meals = (mealPlan["dinner_recipes"] as? [PFObject]) ?? []
        }
 */

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
        
       /* if (meals.count == 0) {
           return cell
        }*/
        
        let date = mealPlan.createdAt!
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        cell.timeCreatedLabel.text = formatter.string(from: date)
        
       // print("printing recipes:")
        //print(meals.)
        cell.mealLabel.text = (meals[0]["label"] as! String)
        cell.caloriesLabel.text = (meals[0]["calories"] as! String)
        
        //if(mealPlan["objectId"].equalTo())
        //print(mealPlan)
        //let user = myMeals["user"] as! PFUser
        //cell.usernameLabel.text = user.username

        /*for meals in myMeals{
            print(counter)
            counter = counter+1
            print(meals)
        }*/
        /* print("tableview print 0th eleemnt of mymeals")
        print(myMeals[0])*/
        
       /* var meals = [PFObject]()
        switch Int.random(in: 0...2) {
        case 0:
            meals = (myMeals["breakfast_recipes"] as? [PFObject]) ?? []
        case 1:
            meals = (myMeals["lunch_recipes"] as? [PFObject]) ?? []
        default:
            meals = (myMeals["dinner_recipes"] as? [PFObject]) ?? []
        }
        
        if (meals.count == 0) {
           return cell
        }*/


                    
    //print("printing the objectIDS: " );
        //print((meal.objectId!))
        /*if(myMealPlan != meal.objectId!){
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileMealsTableViewCell") as! profileMealsTableViewCell
            let user = meal["user"] as! PFUser
            cell.usernameLabel.text = user.username
            let date = meal.createdAt!
            
           /* let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            cell.timeCreatedLabel.text = formatter.string(from: date)
            */
        }*/
        
       // return cell
        //cell.mealLabel.text = post["breakfast_recipe"] as! String

      /*  let imageFile = meals["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!

        cell.mealImageView.af_setImage(withURL: url)
 */
        let mealURL = URL(string: meals[0]["image"] as! String);
        cell.mealImageView.af_setImage(withURL: mealURL!)
        
  
        //
//       let cell = tableView.dequeueReusableCell(withIdentifier: "profileMealsTableViewCell") as! profileMealsTableViewCell
        
 
        
        return cell
    
    }
    

}

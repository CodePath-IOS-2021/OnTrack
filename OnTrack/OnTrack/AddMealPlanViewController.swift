//
//  AddMealPlanViewController.swift
//  OnTrack
//
//  Created by  caijicang on 2021/5/14.
//

import UIKit
import Parse

class AddMealPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mealType = ""       // keep track of which meal to add/remove
    
    // MARK: Setup
    // Three tableViews
    @IBOutlet weak var breakfastTV: UITableView!
    @IBOutlet weak var lunchTV: UITableView!
    @IBOutlet weak var dinnerTV: UITableView!
    
    // Three tableView height constraints
    @IBOutlet weak var breakfastTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lunchTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dinnerTVHeightConstraint: NSLayoutConstraint!
    
    // Three dictionary arrays to keep track of the added recipes
    var breakfastRecipes = [[String:Any]]()
    var lunchRecipes = [[String:Any]]()
    var dinnerRecipes = [[String:Any]]()
    
    // Three dictionary buffers as PFObjects holding the recipe to be added to the database
    var breakfastRecipeArrBuffer = [PFObject]()
    var lunchRecipeArrBuffer = [PFObject]()
    var dinnerRecipeArrBuffer = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // data passing setup
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTV), name: NSNotification.Name(rawValue: "addToMealPlan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(identifyMealType), name: NSNotification.Name(rawValue: "mealType"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTV), name: NSNotification.Name(rawValue: "removeFromMealPlan"), object: nil)
        
        // Table View setup
        breakfastTV.delegate = self
        breakfastTV.dataSource = self
        breakfastTV.backgroundColor = UIColor.clear
        breakfastTV.separatorColor = UIColor.white
        
        lunchTV.delegate = self
        lunchTV.dataSource = self
        lunchTV.backgroundColor = UIColor.clear
        lunchTV.separatorColor = UIColor.white
        
        dinnerTV.delegate = self
        dinnerTV.dataSource = self
        dinnerTV.backgroundColor = UIColor.clear
        dinnerTV.separatorColor = UIColor.white
    }
    
    // MARK: data passing: add/remove meals
    
    // When a new recipe is added, identify its meal type
    @objc func identifyMealType(notification: NSNotification){
        if notification.object as! String == "breakfast" {
            mealType = "breakfast"
        } else if notification.object as! String == "lunch" {
            mealType = "lunch"
        } else {
            mealType = "dinner"
        }

    }
    
    // When a recipe is added/removed, reload the corresponding tableView
    @objc func reloadTV(notification: NSNotification){
        if notification.name.rawValue == "addToMealPlan" {
            if mealType == "breakfast" {
                breakfastRecipes.append(notification.object as! [String:Any])
                breakfastTV.reloadData()
            } else if mealType == "lunch" {
                lunchRecipes.append(notification.object as! [String:Any])
                lunchTV.reloadData()
            } else {
                dinnerRecipes.append(notification.object as! [String:Any])
                dinnerTV.reloadData()
            }
        } else if notification.name.rawValue == "removeFromMealPlan" {
            if mealType == "breakfast" {
                breakfastRecipes.remove(at: notification.object as! Int)
                breakfastTV.reloadData()
            } else if mealType == "lunch" {
                lunchRecipes.remove(at: notification.object as! Int)
                lunchTV.reloadData()
            } else {
                dinnerRecipes.remove(at: notification.object as! Int)
                dinnerTV.reloadData()
            }
        }
        viewWillLayoutSubviews()    // restructure the tableView's layout
    }
    
    // MARK: Segue Config / Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        
        // when clicking an add button, navigate to recipe search page
        if segue.identifier == "addBreakfast" || segue.identifier == "addLunch" || segue.identifier == "addDinner" {
            let nav = segue.destination as! UINavigationController
            let destVC = nav.topViewController as! RecipeViewController
            if segue.identifier == "addBreakfast" {
                destVC.mealType = "breakfast"
            } else if segue.identifier == "addLunch" {
                destVC.mealType = "lunch"
            } else {
                destVC.mealType = "dinner"
            }
        }
        // when clicking a specific line of recipe, navigate to details page
        else {
            let nav = segue.destination as! UINavigationController
            let destVC = nav.topViewController as! RecipeDetailsViewController
            destVC.fromController = "AddMealPlan"
            // locate the current meal cell
            let curr_cell = sender as! MealTableViewCell
            
            if segue.identifier == "seeBreakfastRecipeDetails" {
                let indexPath = breakfastTV.indexPath(for: curr_cell)!
                destVC.recipe = breakfastRecipes[indexPath.row]
                destVC.passedInMealType = "breakfast"
                destVC.indexOfRecipe = indexPath.row
            } else if segue.identifier == "seeLunchRecipeDetails" {
                let indexPath = lunchTV.indexPath(for: curr_cell)!
                destVC.recipe = lunchRecipes[indexPath.row]
                destVC.passedInMealType = "lunch"
                destVC.indexOfRecipe = indexPath.row
            } else {
                let indexPath = dinnerTV.indexPath(for: curr_cell)!
                destVC.recipe = dinnerRecipes[indexPath.row]
                destVC.passedInMealType = "dinner"
                destVC.indexOfRecipe = indexPath.row
            }
        }
        
    }
    
    
    // MARK: Table View Config
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == breakfastTV {
            return breakfastRecipes.count
        } else if tableView == lunchTV {
            return lunchRecipes.count
        }
        return dinnerRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealTableViewCell") as! MealTableViewCell
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        var recipe = [String:Any]()
        
        if tableView == breakfastTV {
            recipe = breakfastRecipes[indexPath.row]
        } else if tableView == lunchTV {
            recipe = lunchRecipes[indexPath.row]
        } else {
            recipe = dinnerRecipes[indexPath.row]
        }
        cell.recipeLabel.text = recipe["label"] as? String
        return cell
    }
    
    // auto-size the height of the tableView
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.breakfastTVHeightConstraint?.constant = breakfastTV.contentSize.height
        self.lunchTVHeightConstraint?.constant = lunchTV.contentSize.height
        self.dinnerTVHeightConstraint?.constant = dinnerTV.contentSize.height
    }
    
    // click the trash button to remove meals
    @IBAction func removeBreakfast(_ sender: UIButton) {
        // locate the current meal cell
        let curr_cell = sender.superview?.superview as! MealTableViewCell
        let indexPath = breakfastTV.indexPath(for: curr_cell)!
        
        // get the current breakfast meal
        breakfastRecipes.remove(at: indexPath.row)
        breakfastTV.reloadData()
        viewWillLayoutSubviews()
        Helper.showToast(controller: self, message: "Recipe removed from breakfast", seconds: 1)
    }
    
    @IBAction func removeLunch(_ sender: UIButton) {
        // locate the current meal cell
        let curr_cell = sender.superview?.superview as! MealTableViewCell
        let indexPath = lunchTV.indexPath(for: curr_cell)!
        
        // get the current breakfast meal
        lunchRecipes.remove(at: indexPath.row)
        lunchTV.reloadData()
        viewWillLayoutSubviews()
        Helper.showToast(controller: self, message: "Recipe removed from lunch", seconds: 1)
    }
    
    @IBAction func removeDinner(_ sender: UIButton) {
        // locate the current meal cell
        let curr_cell = sender.superview?.superview as! MealTableViewCell
        let indexPath = dinnerTV.indexPath(for: curr_cell)!
        
        // get the current breakfast meal
        dinnerRecipes.remove(at: indexPath.row)
        dinnerTV.reloadData()
        viewWillLayoutSubviews()
        Helper.showToast(controller: self, message: "Recipe removed from dinner", seconds: 1)
    }
    
    // MARK: Parse Backend
    // When clicking the add btn, send the meal plan to the Parse backend
    @IBAction func addMealPlanBtn(_ sender: Any) {
        // special case: if no recipe is added, warn the user
        if breakfastRecipes.count == 0 && lunchRecipes.count == 0 && dinnerRecipes.count == 0 {
            Helper.showToast(controller: self, message: "No recipe is added", seconds: 1)
            return
        }
        
        let mealPlan = PFObject(className: "MealPlan")
        mealPlan["user"] = PFUser.current()
    
        // add the customized Recipe objects one by one to the database
        for curr_recipe in breakfastRecipes {
            addRecipeToDatabase(curr_recipe: curr_recipe, mealType: "breakfast")
        }
        for curr_recipe in lunchRecipes {
            addRecipeToDatabase(curr_recipe: curr_recipe, mealType: "lunch")
        }
        for curr_recipe in dinnerRecipes {
            addRecipeToDatabase(curr_recipe: curr_recipe, mealType: "dinner")
        }
        
        // add the collections of Recipe objects as the attributes of MealPlan object
        mealPlan["breakfast_recipes"] = breakfastRecipeArrBuffer
        mealPlan["lunch_recipes"] = lunchRecipeArrBuffer
        mealPlan["dinner_recipes"] = dinnerRecipeArrBuffer
        mealPlan.saveInBackground { success, error in
            if success {
                print("Meal plan saved!")
                
                // append the MealPlan object to the "meal_plans" attribute of the user
                // after the MealPlan object is saved
                let user = PFUser.current()!
                user.add(mealPlan, forKey: "meal_plans")
                user.saveInBackground { success, error in
                    if success {
                        print("User profile saved!")
                    } else {
                        print(error!)
                    }
                }
    
            } else {
                print(error!)
            }
        }
        Helper.showToast(controller: self, message: "Meal Plan Added!", seconds: 1)
        
        // clear the buffer
        breakfastRecipeArrBuffer = [PFObject]()
        lunchRecipeArrBuffer = [PFObject]()
        dinnerRecipeArrBuffer = [PFObject]()

        // dimiss this currently presenting RecipeDetailsViewController after showing toast for 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // add the customized Recipe object to the database
    func addRecipeToDatabase(curr_recipe: [String:Any], mealType: String) {
        let recipe = PFObject(className: "Recipe")
        recipe["label"] = curr_recipe["label"]
        recipe["image"] = curr_recipe["image"]
        recipe["url"] = curr_recipe["url"]
        recipe["ingredients"] = curr_recipe["ingredientLines"]
        
        let caloryNumber = curr_recipe["calories"] as! NSNumber      // calories is a number
        let roundCaloryNumber = round(Double(truncating: caloryNumber) * 100) / 100.0    // round it to 2 decimal places
        recipe["calories"] = String(roundCaloryNumber)         // convert it to a string
        
        if curr_recipe["dishType"] == nil {
            recipe["dishType"] = "None"
        } else {
            let dishTypeArray = curr_recipe["dishType"] as! [String]
            recipe["dishType"] = dishTypeArray[0]
        }
        
        if curr_recipe["cuisineType"] == nil {
            recipe["cuisineType"] = "None"
        } else {
            let cuisineTypeArray = curr_recipe["cuisineType"] as! [String]
            recipe["cuisineType"] = cuisineTypeArray[0]
        }
        
        if curr_recipe["mealType"] == nil {
            recipe["mealType"] = "None"
        } else {
            let mealTypeArray = curr_recipe["mealType"] as! [String]
            recipe["mealType"] = mealTypeArray[0]
        }
        
        recipe.saveInBackground { success, error in
            if success {
                print("Recipe saved!")
            } else {
                print(error!)
            }
        }
        
        if mealType == "breakfast" {
            breakfastRecipeArrBuffer.append(recipe)
        } else if mealType == "lunch" {
            lunchRecipeArrBuffer.append(recipe)
        } else {
            dinnerRecipeArrBuffer.append(recipe)
        }
    }
    
    // MARK: - Navigation
    @IBAction func backToMainScreen(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

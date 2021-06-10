//
//  ProfileViewController.swift
//  OnTrack
//
//  Created by Sophia Lui on 5/19/21.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dateCollectionView: UICollectionView!
    @IBOutlet weak var completeDate: UILabel!       // the complete date label
    
    // Three tableViews
    @IBOutlet weak var breakfastTV: UITableView!
    @IBOutlet weak var lunchTV: UITableView!
    @IBOutlet weak var dinnerTV: UITableView!
    
    // Three tableViews' height constraint
    @IBOutlet weak var breakfastTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lunchTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dinnerTVHeightConstraint: NSLayoutConstraint!
    
    var myMealPlans = [PFObject]()      // store all of current user's meal plans
    var currMealPlan: PFObject?         // store the current meal plan based on the currently selected date
    
    // Three recipe object arrays to keep track of the recipes in the current selected meal plan
    var breakfastRecipes = [PFObject]()
    var lunchRecipes = [PFObject]()
    var dinnerRecipes = [PFObject]()
    
    var dateLength = 7      // length of the date collection view
    var selectedIndex = 0       // store the index of the selected cell in date collection view
    var selectedDate = ""      // store the selected date in the form of "MM-dd-yyyy", for database use
    var selectedDateObject = Date()     // store the selected date object, will be sent to AddMealPlan VC
    
    // all date formatters
    let firstDateFormatter = DateFormatter()
    let secondDateFormatter = DateFormatter()
    let thirdDateFormatter = DateFormatter()
    let fourthDateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateCollectionView.delegate = self
        dateCollectionView.dataSource = self
        breakfastTV.delegate = self
        breakfastTV.dataSource = self
        lunchTV.delegate = self
        lunchTV.dataSource = self
        dinnerTV.delegate = self
        dinnerTV.dataSource = self
        
        firstDateFormatter.dateFormat = "EEEE, dd MMMM"     // "Monday, 07 June
        secondDateFormatter.dateFormat = "E"        // "Mon"
        thirdDateFormatter.dateFormat = "dd"        // "07"
        fourthDateFormatter.dateFormat = "MM-dd-yyyy"       // compare with date in the database
        
        // get today's date
        let today = Date()
        completeDate.text = firstDateFormatter.string(from: today)
        selectedDate = fourthDateFormatter.string(from: today)      // select today by default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadMealPlan()
    }
    
    // MARK: Database request
    @objc func loadMealPlan() {
        let query = PFQuery(className: "MealPlan")
        query.includeKeys(["objectId", "user", "breakfast_recipes", "lunch_recipes", "dinner_recipes"])
        query.limit = 20
        
        if let currentUser = PFUser.current() {
            query.whereKey("user", equalTo: currentUser)
            query.findObjectsInBackground { currentUserMealPlans, Error in
                if currentUserMealPlans != nil {
                    self.myMealPlans = currentUserMealPlans!
                    self.findCurrMealPlan()
                }
            }
        }
    }
    
    // find the current meal plan based on the currently selected date
    func findCurrMealPlan() {
        var found = false   // indicate whether the selected date has a meal plan
        for plan in myMealPlans {
            if plan["date"] as! String == selectedDate {
                currMealPlan = plan
                breakfastRecipes = currMealPlan?["breakfast_recipes"] as! [PFObject]
                lunchRecipes = currMealPlan?["lunch_recipes"] as! [PFObject]
                dinnerRecipes = currMealPlan?["dinner_recipes"] as! [PFObject]
                found = true
                break
            }
        }
        if found == false {
            currMealPlan = nil
            breakfastRecipes = []
            lunchRecipes = []
            dinnerRecipes = []
        }
        breakfastTV.reloadData()
        lunchTV.reloadData()
        dinnerTV.reloadData()
        viewWillLayoutSubviews()    // update tableView heights
    }
    
    // MARK: Segue Config
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addMealPlan" || segue.identifier == "editMealPlan" {
            let nav = segue.destination as! UINavigationController
            let destVC = nav.topViewController as! AddMealPlanViewController
            if segue.identifier == "addMealPlan" {
                destVC.mode = "add"
            } else if segue.identifier == "editMealPlan" {
                if currMealPlan == nil {
                    destVC.mode = "addAndEdit"
                } else if currMealPlan != nil {
                    destVC.mode = "edit"
                    destVC.currMealPlan = currMealPlan
                }
                destVC.passedInDate = selectedDateObject
            }
        }
        
        // when clicking a specific line of recipe, navigate to details page
        else {
            let nav = segue.destination as! UINavigationController
            let destVC = nav.topViewController as! RecipeDetailsViewController
            // locate the current meal cell
            let curr_cell = sender as! MealPlanTableViewCell
            var recipeObj : PFObject?
            if segue.identifier == "seeBreakfastRecipeDetails" {
                let indexPath = breakfastTV.indexPath(for: curr_cell)!
                recipeObj = breakfastRecipes[indexPath.row]
            } else if segue.identifier == "seeLunchRecipeDetails" {
                let indexPath = lunchTV.indexPath(for: curr_cell)!
                recipeObj = lunchRecipes[indexPath.row]
            } else {
                let indexPath = dinnerTV.indexPath(for: curr_cell)!
                recipeObj = dinnerRecipes[indexPath.row]
            }
            var curr_recipe = [String:Any]()    // initialize a new recipe dictionary for data passing
            curr_recipe["label"] = recipeObj?["label"]
            curr_recipe["image"] = recipeObj?["image"]
            curr_recipe["calories"] = recipeObj?["calories"]
            curr_recipe["dishType"] = recipeObj?["dishType"]
            curr_recipe["cuisineType"] = recipeObj?["cuisineType"]
            curr_recipe["mealType"] = recipeObj?["mealType"]
            curr_recipe["ingredientLines"] = recipeObj?["ingredients"]
            curr_recipe["url"] = recipeObj?["url"]
            curr_recipe["mode"] = "editing"     // calories is string, not number, in editing mode
            
            destVC.fromController = "Profile"
            destVC.recipe = curr_recipe
        }
    }
    
    
    // MARK: Date Collection View Config
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateLength
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCell", for: indexPath) as! DateCollectionViewCell
        
        // set up the date components of the cell
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = indexPath.row
        let newDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)!
        
        let dayOfWeek = secondDateFormatter.string(from: newDate)
        let dateOfMonth = thirdDateFormatter.string(from: newDate)
        
        cell.dayOfWeek.text = dayOfWeek
        cell.dateOfMonth.text = dateOfMonth
        
        // set up the colors of the cell
        if indexPath.row != selectedIndex {
            cell.contentView.backgroundColor = UIColor.white
            cell.dayOfWeek.textColor = UIColor.black
        } else if indexPath.row == selectedIndex {
            cell.contentView.backgroundColor = UIColor(red: 0.0889176, green: 0.434948, blue: 0.142683, alpha: 0.72)
            cell.dayOfWeek.textColor = UIColor.white
            selectedDate = fourthDateFormatter.string(from: newDate)    // update selectedDate here
            selectedDateObject = newDate
            completeDate.text = firstDateFormatter.string(from: newDate)
            findCurrMealPlan()      // update current selected meal plan
        }
        
        return cell
    }
    
    // when selecting a new cell, change the selectedIndex
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
    
    
    // MARK: MealPlan TableView Config
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == breakfastTV {
            return breakfastRecipes.count
        } else if tableView == lunchTV {
            return lunchRecipes.count
        }
        return dinnerRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealPlanTableViewCell") as! MealPlanTableViewCell
        var recipe: PFObject?
        
        if tableView == breakfastTV {
            recipe = breakfastRecipes[indexPath.row]
        } else if tableView == lunchTV {
            recipe = lunchRecipes[indexPath.row]
        } else if tableView == dinnerTV {
            recipe = dinnerRecipes[indexPath.row]
        }
        
        cell.meal_label.text = recipe?["label"] as? String
        cell.meal_calories.text = recipe?["calories"] as? String
        let imageUrl = URL(string: recipe?["image"] as! String)
        cell.meal_image.af.setImage(withURL: imageUrl!)
        
        return cell
    }
    
    // auto-size the height of the tableView
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.breakfastTVHeightConstraint?.constant = breakfastTV.contentSize.height
        self.lunchTVHeightConstraint?.constant = lunchTV.contentSize.height
        self.dinnerTVHeightConstraint?.constant = dinnerTV.contentSize.height
    }
    
    // MARK: Logout
    @IBAction func onLogoutBtn(_ sender: Any) {
        PFUser.logOut()     // clear the parse cache
        // navigate back to the login screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "loginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController = loginViewController
    }
    
}

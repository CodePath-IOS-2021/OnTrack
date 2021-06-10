//
//  AddMealPlanViewController.swift
//  OnTrack
//
//  Created by  caijicang on 2021/5/14.
//

import UIKit
import Parse

// We can either add or edit meal plan
class AddMealPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // global indicator variable
    var mealType = ""       // keep track of which type of meal to add/remove
    var mode = "add"   // indicate whether we are adding or editing a meal plan
    
    // for editing only
    var currMealPlan: PFObject?     // store the current meal plan we are editing
    var passedInDate = Date()       // store the date of the current meal plan we are editing
    
    var passedInBreakfastRecipes = [PFObject]()     // store breakfast recipe from the passed in meal plan
    var passedInLunchRecipes = [PFObject]()
    var passedInDinnerRecipes = [PFObject]()
    
    var removedBreakfastRecipes = [PFObject]()  // store breakfast recipes that are removed
    var removedLunchRecipes = [PFObject]()
    var removedDinnerRecipes = [PFObject]()
    
    // MARK: Setup
    // Three tableViews
    @IBOutlet weak var breakfastTV: UITableView!
    @IBOutlet weak var lunchTV: UITableView!
    @IBOutlet weak var dinnerTV: UITableView!
    
    // Three tableView height constraints
    @IBOutlet weak var breakfastTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lunchTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dinnerTVHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var bottomBtn: UIButton!
    
    // for editing only
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var deleteBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteBtnBottomConstraint: NSLayoutConstraint!
    // popup window
    @IBOutlet var popupView: UIView!
    @IBOutlet var blurView: UIVisualEffectView!
    
    // Three dictionary arrays to keep track of the added recipes
    var breakfastRecipes = [[String:Any]]()
    var lunchRecipes = [[String:Any]]()
    var dinnerRecipes = [[String:Any]]()
    
    // Three dictionary buffers as PFObjects holding the recipe to be added to the database
    var breakfastRecipeArrBuffer = [PFObject]()
    var lunchRecipeArrBuffer = [PFObject]()
    var dinnerRecipeArrBuffer = [PFObject]()
    
    let dateFormatter = DateFormatter()
    
    var myMealPlans = [PFObject]()      // store all meal plans created by the current user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populate the mealPlan cards if editing
        if mode == "add" {
            self.title = "Add a meal plan"
            deleteBtn.isHidden = true
            deleteBtnHeightConstraint.constant = 0
            deleteBtnBottomConstraint.constant = 0
        } else if mode == "edit" {
            self.title = "Edit the meal plan"
            bottomBtn.setTitle("Finishing editing", for: .normal)
            deleteBtn.isHidden = false
            datePicker.date = passedInDate
            if currMealPlan != nil {
                passedInBreakfastRecipes = currMealPlan?["breakfast_recipes"] as! [PFObject]
                passedInLunchRecipes = currMealPlan?["lunch_recipes"] as! [PFObject]
                passedInDinnerRecipes = currMealPlan?["dinner_recipes"] as! [PFObject]
                populateMealPlan()
                
                // popup window config
                blurView.bounds = self.view.bounds
                popupView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8, height: self.view.bounds.height * 0.3)
            }
        } else if mode == "addAndEdit" {
            self.title = "Add a meal plan"
            deleteBtn.isHidden = true
            deleteBtnHeightConstraint.constant = 0
            deleteBtnBottomConstraint.constant = 0
            datePicker.date = passedInDate
        }
        
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
        
        // datePicker config
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        // reload Table Views
        breakfastTV.reloadData()
        lunchTV.reloadData()
        dinnerTV.reloadData()
        self.loadMyMealPlans()
        viewWillLayoutSubviews()
    }
        
    // if we are editing a meal plan, populate the three cards
    // only called during editing mode
    // have to manually populate the information because [PFObject] cannot be cast to [[String:Any]]
    func populateMealPlan() {
        var index = 0
        for recipe in passedInBreakfastRecipes {
            var curr_recipe = [String:Any]()    // initialize a new recipe
            curr_recipe["label"] = recipe["label"]
            curr_recipe["image"] = recipe["image"]
            curr_recipe["calories"] = recipe["calories"]
            curr_recipe["dishType"] = recipe["dishType"]
            curr_recipe["cuisineType"] = recipe["cuisineType"]
            curr_recipe["mealType"] = recipe["mealType"]
            curr_recipe["ingredientLines"] = recipe["ingredients"]
            curr_recipe["url"] = recipe["url"]
            curr_recipe["mode"] = "editing"     // calories is string, not number, in editing mode
            curr_recipe["original_index"] = index   // the recipe's original index in the passed in meal plan
            index += 1
            breakfastRecipes.append(curr_recipe)
        }
        index = 0
        for recipe in currMealPlan?["lunch_recipes"] as! [PFObject] {
            var curr_recipe = [String:Any]()    // initialize a new recipe
            curr_recipe["label"] = recipe["label"]
            curr_recipe["image"] = recipe["image"]
            curr_recipe["calories"] = recipe["calories"]
            curr_recipe["dishType"] = recipe["dishType"]
            curr_recipe["cuisineType"] = recipe["cuisineType"]
            curr_recipe["mealType"] = recipe["mealType"]
            curr_recipe["ingredientLines"] = recipe["ingredients"]
            curr_recipe["url"] = recipe["url"]
            curr_recipe["mode"] = "editing"
            curr_recipe["original_index"] = index
            index += 1
            lunchRecipes.append(curr_recipe)
        }
        index = 0
        for recipe in currMealPlan?["dinner_recipes"] as! [PFObject] {
            var curr_recipe = [String:Any]()    // initialize a new recipe
            curr_recipe["label"] = recipe["label"]
            curr_recipe["image"] = recipe["image"]
            curr_recipe["calories"] = recipe["calories"]
            curr_recipe["dishType"] = recipe["dishType"]
            curr_recipe["cuisineType"] = recipe["cuisineType"]
            curr_recipe["mealType"] = recipe["mealType"]
            curr_recipe["ingredientLines"] = recipe["ingredients"]
            curr_recipe["url"] = recipe["url"]
            curr_recipe["mode"] = "editing"
            curr_recipe["original_index"] = index
            index += 1
            dinnerRecipes.append(curr_recipe)
        }
    }
    
    
    // load all my meal plans
    @objc func loadMyMealPlans() {
        let query = PFQuery(className: "MealPlan")
        // fetch all meal plans from the current user
        if let currentUser = PFUser.current() {
            query.whereKey("user", equalTo: currentUser)
            query.findObjectsInBackground { currentUserMealPlans, Error in
                if currentUserMealPlans != nil {
                    self.myMealPlans = currentUserMealPlans!
                }
            }
        }
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
                // if the recipe object is in the database, mark it as removed
                let currRecipe = breakfastRecipes[notification.object as! Int]
                if currRecipe["mode"] as? String == "editing" {
                    let index = currRecipe["original_index"] as! Int     // the recipe's index in the passed in breakfast_recipe array
                    let recipe_object = passedInBreakfastRecipes[index]
                    removedBreakfastRecipes.append(recipe_object)
                }
                breakfastRecipes.remove(at: notification.object as! Int)
                breakfastTV.reloadData()
            } else if mealType == "lunch" {
                let currRecipe = lunchRecipes[notification.object as! Int]
                if currRecipe["mode"] as? String == "editing" {
                    let index = currRecipe["original_index"] as! Int
                    let recipe_object = passedInLunchRecipes[index]
                    removedLunchRecipes.append(recipe_object)
                }
                lunchRecipes.remove(at: notification.object as! Int)
                lunchTV.reloadData()
            } else {
                let currRecipe = dinnerRecipes[notification.object as! Int]
                if currRecipe["mode"] as? String == "editing" {
                    let index = currRecipe["original_index"] as! Int
                    let recipe_object = passedInDinnerRecipes[index]
                    removedDinnerRecipes.append(recipe_object)
                }
                dinnerRecipes.remove(at: notification.object as! Int)
                dinnerTV.reloadData()
            }
        }
        viewWillLayoutSubviews()    // restructure the tableView's layout/height
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
        breakfastTVHeightConstraint?.constant = breakfastTV.contentSize.height
        lunchTVHeightConstraint?.constant = lunchTV.contentSize.height
        dinnerTVHeightConstraint?.constant = dinnerTV.contentSize.height
    }
    
    // MARK: remove icons
    // click the trash button to remove meals
    @IBAction func removeBreakfast(_ sender: UIButton) {
        // locate the current meal cell
        let curr_cell = sender.superview?.superview as! MealTableViewCell
        let indexPath = breakfastTV.indexPath(for: curr_cell)!
        
        // if the recipe object is in the database, mark it as removed
        let currRecipe = breakfastRecipes[indexPath.row]
        if currRecipe["mode"] as? String == "editing" {
            let index = currRecipe["original_index"] as! Int     // the recipe's index in the passed in breakfast_recipe array
            let recipe_object = passedInBreakfastRecipes[index]
            removedBreakfastRecipes.append(recipe_object)
        }
        
        breakfastRecipes.remove(at: indexPath.row)
        breakfastTV.reloadData()
        viewWillLayoutSubviews()
        Helper.showToast(controller: self, message: "Recipe removed from breakfast", seconds: 1)
    }
    
    @IBAction func removeLunch(_ sender: UIButton) {
        // locate the current meal cell
        let curr_cell = sender.superview?.superview as! MealTableViewCell
        let indexPath = lunchTV.indexPath(for: curr_cell)!
        
        let currRecipe = lunchRecipes[indexPath.row]
        if currRecipe["mode"] as? String == "editing" {
            let index = currRecipe["original_index"] as! Int     // the recipe's index in the passed in breakfast_recipe array
            let recipe_object = passedInLunchRecipes[index]
            removedLunchRecipes.append(recipe_object)
        }
        
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
        
        let currRecipe = dinnerRecipes[indexPath.row]
        if currRecipe["mode"] as? String == "editing" {
            let index = currRecipe["original_index"] as! Int     // the recipe's index in the passed in breakfast_recipe array
            let recipe_object = passedInDinnerRecipes[index]
            removedDinnerRecipes.append(recipe_object)
        }
        
        // get the current breakfast meal
        dinnerRecipes.remove(at: indexPath.row)
        dinnerTV.reloadData()
        viewWillLayoutSubviews()
        Helper.showToast(controller: self, message: "Recipe removed from dinner", seconds: 1)
    }
    
    // MARK: Parse Backend
    // When clicking the add btn, send the meal plan to the Parse backend, or edit an existing meal plan
    @IBAction func addMealPlanBtn(_ sender: Any) {
        
        // special case: if no recipe is added, warn the user
        if breakfastRecipes.count == 0 && lunchRecipes.count == 0 && dinnerRecipes.count == 0 {
            Helper.showToast(controller: self, message: "No recipe is added", seconds: 1)
            return
        }
        
        // MARK: Database adding
        if mode == "add" || mode == "addAndEdit"{
            let mealPlan = PFObject(className: "MealPlan")
            mealPlan["user"] = PFUser.current()
            
            // add the selected date for the meal plan as a string
            let selectedDate = dateFormatter.string(from: datePicker.date)
            if isDuplicateDate(date: selectedDate) {
                Helper.showToast(controller: self, message: "This date already has a meal plan", seconds: 1)
                return
            } else {
                mealPlan["date"] = selectedDate
            }
        
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
            // dimiss this currently presenting RecipeDetailsViewController after showing toast for 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        
        // MARK: Database updating
        else if mode == "edit" {
            let query = PFQuery(className: "MealPlan")
            query.getObjectInBackground(withId: (currMealPlan?.objectId)!) { fetchedMealPlan, error in
                if fetchedMealPlan != nil {
                    // update meal plan date if changed
                    let selectedDate = self.dateFormatter.string(from: self.datePicker.date)
                    if selectedDate != fetchedMealPlan?["date"] as? String {
                        if self.isDuplicateDate(date: selectedDate) {
                            Helper.showToast(controller: self, message: "This date already has a meal plan", seconds: 1)
                            return
                        } else {
                            fetchedMealPlan?["date"] = selectedDate
                        }
                    }
                    
                    // update recipes if changed
                    for curr_recipe in self.breakfastRecipes {
                        if curr_recipe["mode"] as? String == "editing" {
                            let index = curr_recipe["original_index"] as! Int
                            self.breakfastRecipeArrBuffer.append(self.passedInBreakfastRecipes[index])
                        } else {
                            self.addRecipeToDatabase(curr_recipe: curr_recipe, mealType: "breakfast")
                        }
                    }
                    
                    for curr_recipe in self.lunchRecipes {
                        if curr_recipe["mode"] as? String == "editing" {
                            let index = curr_recipe["original_index"] as! Int
                            self.lunchRecipeArrBuffer.append(self.passedInLunchRecipes[index])
                        } else {
                            self.addRecipeToDatabase(curr_recipe: curr_recipe, mealType: "lunch")
                        }
                    }
                    
                    for curr_recipe in self.dinnerRecipes {
                        if curr_recipe["mode"] as? String == "editing" {
                            let index = curr_recipe["original_index"] as! Int
                            self.dinnerRecipeArrBuffer.append(self.passedInDinnerRecipes[index])
                        } else {
                            self.addRecipeToDatabase(curr_recipe: curr_recipe, mealType: "dinner")
                        }
                    }
                    
                    // delete the removed recipes in the database
                    for curr_recipe in self.removedBreakfastRecipes {
                        curr_recipe.deleteInBackground()
                    }
                    for curr_recipe in self.removedLunchRecipes {
                        curr_recipe.deleteInBackground()
                    }
                    for curr_recipe in self.removedDinnerRecipes {
                        curr_recipe.deleteInBackground()
                    }
                    
                    
                    fetchedMealPlan?["breakfast_recipes"] = self.breakfastRecipeArrBuffer
                    fetchedMealPlan?["lunch_recipes"] = self.lunchRecipeArrBuffer
                    fetchedMealPlan?["dinner_recipes"] = self.dinnerRecipeArrBuffer
                    
                    fetchedMealPlan?.saveInBackground(block: { success, error in
                        if success {
                            print("Meal Plan updated!")
                        } else {
                            print(error!)
                        }
                    })
                    
                    Helper.showToast(controller: self, message: "Meal Plan Updated!", seconds: 1)
                    // dimiss this currently presenting RecipeDetailsViewController after showing toast for 1 second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        // clear the buffer
        breakfastRecipeArrBuffer = [PFObject]()
        lunchRecipeArrBuffer = [PFObject]()
        dinnerRecipeArrBuffer = [PFObject]()

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
    
    // check if the selected date already has a meal plan
    func isDuplicateDate(date: String) -> Bool {
        for plan in myMealPlans {
            if plan["date"] as! String == date {
                return true
            }
        }
        return false
    }
    
    // MARK: popup window for deletion
    // delete meal plan Btn
    @IBAction func deleteMealPlanBtn(_ sender: Any) {
        animateIn(desiredView: blurView)
        animateIn(desiredView: popupView)
    }
    
    @IBAction func confirmDelete(_ sender: Any) {
        animateOut(desiredView: popupView)
        animateOut(desiredView: blurView)
        
        // delete all recipe objects and the meal plan object
        for recipe in passedInBreakfastRecipes {
            recipe.deleteInBackground()
        }
        for recipe in passedInLunchRecipes {
            recipe.deleteInBackground()
        }
        for recipe in passedInDinnerRecipes {
            recipe.deleteInBackground()
        }
        
        let user = PFUser.current()
        var new_mealPlan = [PFObject]()
        
        for plan in user?["meal_plans"] as! [PFObject] {
            if plan.objectId != currMealPlan?.objectId {
                new_mealPlan.append(plan)
            }
        }
        // reset the "meal_plans" attribute of the current user
        user?["meal_plans"] = new_mealPlan
        user?.saveInBackground(block: { success, error in
            if success {
                print("User profile updated")
                self.currMealPlan?.deleteInBackground(block: { success, error in
                    if success {
                        print("meal plan deleted")
                    } else {
                        print(error!)
                    }
                })
            } else {
                print(error!)
            }
        })
    
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelDelete(_ sender: Any) {
        animateOut(desiredView: popupView)
        animateOut(desiredView: blurView)
    }
    
    // Animate in a specified View
    func animateIn(desiredView: UIView) {
        let backgroundView = self.view!
        // attach our desired view to the screen (self.view)
        backgroundView.addSubview(desiredView)
        
        // sets the view's scaling to be 120% at the beginning
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0   // start the transparency from 0% to 100%
        desiredView.center = backgroundView.center
        
        // animate the effect
        UIView.animate(withDuration: 0.3) {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1   // start the transparency from 0 to 100
        }
    }
    
    // Animate out a specified view
    func animateOut(desiredView: UIView) {
        UIView.animate(withDuration: 0.3) {
            desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            desiredView.alpha = 0
        } completion: { _ in
            desiredView.removeFromSuperview()
        }

    }
    
    // MARK: - Navigation
    // back btn
    @IBAction func backToMainScreen(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

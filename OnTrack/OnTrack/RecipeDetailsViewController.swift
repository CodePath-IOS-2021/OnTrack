//
//  RecipeDetailsViewController.swift
//  OnTrack
//
//  Created by caijicang on 2021/5/22.
//

import UIKit

class RecipeDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // outlets
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalCalories: UILabel!
    @IBOutlet weak var dishType: UILabel!
    @IBOutlet weak var cuisineType: UILabel!
    @IBOutlet weak var mealType: UILabel!
    @IBOutlet weak var ingredientsTV: UITableView!
    @IBOutlet weak var ingredientsTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBtn: UIButton!
    
    // arguments passed in by the previous ViewController
    var recipe: [String:Any]!
    var passedInMealType: String = ""
    var fromController: String = ""     // indicate the previous view controller
    var indexOfRecipe = 0       // the index of the clicked recipe from the meal plan screen
    
    // local arguments
    var ingredientsArray: [String] = []     // store the ingredients of the recipe
    var fullRecipeURL: String = ""      // the url to the full detailed recipe
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Recipe Details Config
        let imagePath = recipe["image"] as! String
        let imageUrl = URL(string: imagePath)!
        image.af.setImage(withURL: imageUrl)
        
        titleLabel.text = recipe["label"] as? String
        titleLabel.textAlignment = NSTextAlignment.center
        
        let caloryNumber = recipe["calories"] as! NSNumber      // calories is a number
        let roundCaloryNumber = round(Double(truncating: caloryNumber) * 100) / 100.0    // round it to 2 decimal places
        totalCalories.text = String(roundCaloryNumber)         // convert it to a string
        
        if recipe["dishType"] == nil {
            dishType.text = "None"
        } else {
            let dishTypeArray = recipe["dishType"] as! [String]
            dishType.text = dishTypeArray[0]
        }
        
        if recipe["cuisineType"] == nil {
            cuisineType.text = "None"
        } else {
            let cuisineTypeArray = recipe["cuisineType"] as! [String]
            cuisineType.text = cuisineTypeArray[0]
        }
        
        if recipe["mealType"] == nil {
            mealType.text = "None"
        } else {
            let mealTypeArray = recipe["mealType"] as! [String]
            mealType.text = mealTypeArray[0]
        }
        
        ingredientsTV.delegate = self
        ingredientsTV.dataSource = self
        
        ingredientsArray = recipe["ingredientLines"] as! [String]
        
        fullRecipeURL = (recipe["url"] as? String)!
        
        // determine the style of the button at the bottom
        if fromController == "AddMealPlan" {
            bottomBtn.setTitle("Remove from meal plan", for: .normal)
            bottomBtn.backgroundColor = UIColor.red
        }
    }
    
    // MARK: - Ingredient Table View Config
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ingredientsTV.dequeueReusableCell(withIdentifier: "IngredientTVCell") as! IngredientTVCell
        let ingredient = ingredientsArray[indexPath.row]
        cell.ingredientLabel.text = ingredient
        return cell
    }
    
    // auto-size the height of the tableView
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        ingredientsTVHeightConstraint?.constant = ingredientsTV.contentSize.height
    }
    
    // When clicking "Full Recipe", navigate to an external link
    @IBAction func seeFullRecipe(_ sender: Any) {
        UIApplication.shared.open(URL(string: fullRecipeURL)! as URL, options: [:], completionHandler: nil)
    }
    
    /*
     * When the bottom button is clicked, add/remove it to/from the meal plan
     */
    @IBAction func addOrRemoveRecipe(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mealType"), object: passedInMealType)
        
        if fromController == "Recipe" {
            // send the recipe object to AddMealPlan ViewController
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addToMealPlan"), object: recipe)
            Helper.showToast(controller: self, message: "Recipe added to \(passedInMealType)!", seconds: 1)
        }
        else if fromController == "AddMealPlan" {
            // send the passed in index of the recipe object to the MealPlan ViewController
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeFromMealPlan"), object: indexOfRecipe)
            Helper.showToast(controller: self, message: "Recipe removed from \(passedInMealType)!", seconds: 1)
        }
        
        // dimiss this currently presenting RecipeDetailsViewController
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }


}

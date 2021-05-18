//
//  AddMealPlanViewController.swift
//  OnTrack
//
//  Created by  caijicang on 2021/5/14.
//

import UIKit

class AddMealPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mealType = ""       // keep track of which meal to add
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // data passing
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTV), name: NSNotification.Name(rawValue: "reloadTV"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(identifyMealType), name: NSNotification.Name(rawValue: "mealType"), object: nil)
        
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
    
    // When a new recipe is added, reload the tableViews
    @objc func reloadTV(notification: NSNotification){
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
        viewWillLayoutSubviews()
    }
    
    // MARK: Segue Config / Navigation
    @IBAction func addBreakfast(_ sender: Any) {
        performSegue(withIdentifier: "addBreakfast", sender: self)
    }
    
    @IBAction func addLunch(_ sender: Any) {
        performSegue(withIdentifier: "addLunch", sender: self)
    }
    
    @IBAction func addDinner(_ sender: Any) {
        performSegue(withIdentifier: "addDinner", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
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

    // auto-size the height of the tableView
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.breakfastTVHeightConstraint?.constant = breakfastTV.contentSize.height
        self.lunchTVHeightConstraint?.constant = lunchTV.contentSize.height
        self.dinnerTVHeightConstraint?.constant = dinnerTV.contentSize.height
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
    
}

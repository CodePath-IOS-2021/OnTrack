//
//  RecipeViewController.swift
//  OnTrack
//
//  Created by bennycai on 2021/5/9.
//

import UIKit
import AlamofireImage
import MaterialComponents.MaterialChips

class RecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Setup
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    @IBOutlet var caloryTagsCollectionView: UICollectionView!
    
    var recipeDict = [[String:Any]]()          // dictionary to hold the recipe JSON object
    let caloryTags = ["< 200", "200 - 400", "400 - 600", "> 600"]
    var selectedCaloryTags: [String] = []       // keep track of the selected calory tags

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeTableView.dataSource = self
        recipeTableView.delegate = self
        
        recipeSearchBar.delegate = self
        caloryTagsCollectionView.delegate = self
        caloryTagsCollectionView.dataSource = self
        
        // set up the chip CollectionView for calory tags
        let layout = MDCChipCollectionViewFlowLayout()
        caloryTagsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        sendRequest()      // send an initial empty network request
    }
  
    // called when the view starts loading
    override func loadView() {
        super.loadView()
        
        // register chip cell for the chip CollectionView
        caloryTagsCollectionView.register(
            MDCChipCollectionViewCell.self,
            forCellWithReuseIdentifier: "CaloryTagCell")
        caloryTagsCollectionView.allowsMultipleSelection = true
    }
    
    // MARK: Network Request
    // constant API key and id
    let app_id = "a88f7131"
    let app_key = "5a4cd86659de2dc4bb22022785af1c61"
    
    // number of recipes displayed at each round
    let from = 0
    let to = 20
    
    // recipe search filters
    var query = ""
    var caloryRange = "0%2B"    // default calory range: 0+
    var mealType = ""         // meal type is passed in by the previous view controller

    /*
     * The function for sending the network request
     */
    func sendRequest() {
        let url = URL(string: "https://api.edamam.com/search?q=\(query)&app_id=\(app_id)&app_key=\(app_key)&from=\(from)&to=\(to)&calories=\(caloryRange)&mealType=\(mealType)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            self.recipeDict = dataDictionary["hits"] as! [[String:Any]]
            self.recipeTableView.reloadData()
           }
        }
        task.resume()
    }
    
    // MARK: Search Bar Config
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let userInput = recipeSearchBar.text! as String
        recipeSearchBar.endEditing(true)
        query = userInput
        sendRequest()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        recipeSearchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        recipeSearchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        recipeSearchBar.text = ""
        recipeSearchBar.setShowsCancelButton(false, animated: true)
        recipeSearchBar.endEditing(true)
    }
    
    
    
    // MARK: Table View Config
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeTableViewCell") as! recipeTableViewCell
        
        let recipeDictionary = recipeDict[indexPath.row] as [String:Any]
        let recipe = recipeDictionary["recipe"] as! [String:Any]
        
        cell.recipeTitle.text = recipe["label"] as? String
        let caloryNumber = recipe["calories"] as! NSNumber      // calories is a number
        let roundCaloryNumber = round(Double(truncating: caloryNumber) * 100) / 100.0    // round it to 2 decimal places
        cell.calories.text = String(roundCaloryNumber)         // convert it to a string
        
        let imagePath = recipe["image"] as! String
        let imageUrl = URL(string: imagePath)!
        cell.recipeImage.af.setImage(withURL: imageUrl)
        
        return cell
    }
    
    /*
     * When the add button of a recipe is clicked, add it to the meal plan
     */
    @IBAction func addRecipe(_ sender: UIButton) {
        // locate the current cell
        let curr_cell = sender.superview?.superview as! recipeTableViewCell
        let indexPath = recipeTableView.indexPath(for: curr_cell)!
        
        // get the current recipe object
        let recipeDictionary = recipeDict[indexPath.row] as [String:Any]
        let recipe = recipeDictionary["recipe"] as! [String:Any]
        showToast(controller: self, message: "Recipe added to \(mealType)!", seconds: 1)
        
        // send the recipe object to AddMealPlan ViewController
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mealType"), object: mealType)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTV"), object: recipe)
    }
    
    
    // MARK: Tags Collection View Config
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return caloryTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CaloryTagCell", for: indexPath) as! MDCChipCollectionViewCell
        let chipView = cell.chipView
        
        // configure the chipView to be a filter chip
        let tag = caloryTags[indexPath.item]
        chipView.titleLabel.text = tag
        chipView.setTitleColor(UIColor.white, for: .selected)
        chipView.setBackgroundColor(UIColor.red, for: .selected)
        chipView.sizeToFit()
        return cell
    }
    
    // when the user selects/deselects a tag, update the calory range
    func updateCaloryRange() {
        // determine the range of calories from the selected tags
        var min = -1
        var max = -1
        for tag in selectedCaloryTags {
            if (tag == "< 200") {
                min = 0
                if (max == -1) {
                    max = 200
                }
            } else if (tag == "200 - 400") {
                if (min == -1 || min > 200) {
                    min = 200
                }
                if (max == -1 || max < 400) {
                    max = 400
                }
            } else if (tag == "400 - 600") {
                if (min == -1 || min > 400) {
                    min = 400
                }
                if (max == -1 || max < 600) {
                    max = 600
                }
            } else if (tag == "> 600") {
                max = -2    // let max = -2 if there is no upper limit
                if (min == -1) {
                    min = 600
                }
            }
        }
        
        // construct the caloryRange string
        if (max == -2) {
            caloryRange = "\(min)%2B"
        } else if (max == -1) {
            caloryRange = "0%2B"
        } else {
            caloryRange = "\(min)-\(max)"
        }
        sendRequest()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // add the selected tag to the selectedCaloryTags array
        selectedCaloryTags.append(caloryTags[indexPath.item])
        updateCaloryRange()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // remove the deselected tag from the selectedCaloryTags array
        let deselectedTag = caloryTags[indexPath.item]
        for (index, tag) in selectedCaloryTags.enumerated() {
            if tag == deselectedTag {
                selectedCaloryTags.remove(at: index)
            }
        }
        updateCaloryRange()
    }
    
    
    // MARK: Helper functions
    func showToast(controller: UIViewController, message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
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

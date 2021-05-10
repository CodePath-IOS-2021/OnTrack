//
//  RecipeViewController.swift
//  OnTrack
//
//  Created by bennycai on 2021/5/9.
//

import UIKit
import AlamofireImage

class RecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // constant API key and id
    let app_id = "a88f7131"
    let app_key = "5a4cd86659de2dc4bb22022785af1c61"
    
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    
    var recipeDict = [[String:Any]]()          // dictionary to hold the recipe JSON object

    override func viewDidLoad() {
        super.viewDidLoad()

        recipeTableView.dataSource = self
        recipeTableView.delegate = self
        
        recipeSearchBar.delegate = self
        
        sendRequest(userInput: "")      // send an initial network request with empty query
    }
    
    // MARK: Search Bar Config
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sendRequest(userInput: searchText)
    }
    
    /*
     * The function for sending the network request
     */
    func sendRequest(userInput: String) {
        let query = userInput
        let from = 0
        let to = 20
        let calories = "200-400"
        let health = "alcohol-free"
        
        let url = URL(string: "https://api.edamam.com/search?q=\(query)&app_id=\(app_id)&app_key=\(app_key)&from=\(from)&to=\(to)&calories=\(calories)&health=\(health)")!
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
    
    // MARK: Table View Config
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeTableViewCell") as! recipeTableViewCell
        
        let recipeDict = recipeDict[indexPath.row] as [String:Any]
        let recipe = recipeDict["recipe"] as! [String:Any]
        
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

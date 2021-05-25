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
    
    var posts = [PFObject]()

    @IBOutlet weak var mealsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealsTableView.delegate = self
        mealsTableView.dataSource = self

    }

    override func viewDidAppear(_ animated: Bool) {
        // refresh again
        super.viewDidAppear(animated)
        
        // Activate query
        // creating the clsas
        let query = PFQuery(className: "MealPlan")
        
        // include key
        query.includeKeys(["user", "createdAt", "dinner_recipes"])
        query.limit = 20; // last 20
        query.findObjectsInBackground{ (posts, error) in
            // store data
            if posts != nil{
                // refresh
                self.posts = posts!
                self.mealsTableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileMealsTableViewCell") as! profileMealsTableViewCell

        let post = posts[indexPath.row]

        let user = post["user"] as! PFUser
        cell.usernameLabel.text = user.username

        //cell.mealLabel.text = post["breakfast_recipe"] as! String

        /*let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!

        cell.mealImageView.af_setImage(withURL: url)
 */ 
        return cell
       /* let cell = tableView.dequeueReusableCell(withIdentifier: "profileMealsTableViewCell") as! profileMealsTableViewCell
        return cell*/
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

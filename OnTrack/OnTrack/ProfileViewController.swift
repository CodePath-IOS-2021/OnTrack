//
//  ProfileViewController.swift
//  OnTrack
//
//  Created by Sophia Lui on 5/19/21.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var mealsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealsTableView.delegate = self
        mealsTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileMealsTableViewCell") as! profileMealsTableViewCell
        
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

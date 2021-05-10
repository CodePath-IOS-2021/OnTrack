//
//  ViewController.swift
//  OnTrack
//
//  Created by  caijicang on 2021/5/9.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onAddRecipe(_ sender: Any) {
        performSegue(withIdentifier: "addRecipe", sender: self)
    }
    
}


//
//  Helper.swift
//  OnTrack
//
//  Created by  caijicang on 2021/5/24.
//

import UIKit
import Foundation

// A class to store all the static helper functions

class Helper {
    static func showToast(controller: UIViewController, message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}

//
//  AlertFunctions.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/29/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import Foundation
import UIKit

class AlertFunctions: UIViewController {
    
    func showAlert(_ alertTitle: String, msg: String) {
     DispatchQueue.main.async {
        let alertController = UIAlertController(title: alertTitle, message:msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
        
        }
    }
}

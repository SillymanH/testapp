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
    
    func showAlert(_ classInstance: AnyObject,_ alertTitle: String, msg: String) {
        
     DispatchQueue.main.async {
        
        let alertController = UIAlertController(title: alertTitle, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        classInstance.present(alertController, animated: true, completion: nil)
        
        }
    }
    
    func showActionAlert(_ classInstance: AnyObject ,_ alertTitle: String,_ msg: String,_ action: UIAlertAction) {
        
        DispatchQueue.main.async {
            
            let Alert = UIAlertController(title: alertTitle, message: msg, preferredStyle: .alert)
            Alert.addAction(action)
            classInstance.present(Alert, animated: true, completion: nil)
            
        }
    }
}

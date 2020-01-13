//
//  AlertFunctions.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/29/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import Foundation
import UIKit

class AlertFunctions {
    
    var vSpinner : UIView?
    
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
    
    func showSpinner(onView: UIView) {
        
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let spinner = UIActivityIndicatorView.init(style: .large)
        spinner.startAnimating()
        spinner.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(spinner)
            onView.addSubview(spinnerView)
           }
           
           vSpinner = spinnerView
       }
       
       func removeSpinner() {
           DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
           }
       }
}

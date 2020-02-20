//
//  ResetPasswordViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 2/21/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var passwordField1: UITextField!
    @IBOutlet weak var passwordField2: UITextField!
    
    let alert = AlertFunctions()
    let http = HTTPFunctions()
    
    let resetPasswordAPI = "http://localhost:8888/test_db/ResetPassword.php"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func resetBtnPressed(_ sender: UIButton) {
        
        if passwordField1.text!.isEmpty || passwordField2.text!.isEmpty {
            
            alert.showAlert(self, "Error", msg: "All fields are required")
                return
        }
        
        if !(passwordField1.text == passwordField2.text) {
            
            alert.showAlert(self, "Error", msg: "Passwords do not match")
                return
        }
        
        let params = "newPassword=" + passwordField1.text!
        http.DoRequestReturnJSON(resetPasswordAPI, params, "POST", CustomRequest: nil) { json in
            
            guard let response = json as? NSDictionary else {
                
                self.alert.showAlert(self, "Error", msg: "Something went wrong!")
                    return
            }
            guard ((response["success"] as? Int) == 1) else {
                
                self.alert.showAlert(self ,"Error", msg: response["info"] as! String)
                    return
            }
            
            DispatchQueue.main.async {
                       
                       let LoggedInVC = self.storyboard?.instantiateViewController(withIdentifier: "LoggedInViewController")
                       self.present(LoggedInVC!, animated: true, completion: nil)
                   }
        }
    }
}

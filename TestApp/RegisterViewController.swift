//
//  RegisterViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/23/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var _fullname: UITextField!
    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField!
    //TODO: Implement confirm password field
    @IBOutlet weak var _email: UITextField!
    @IBOutlet weak var _mobileNumber: UITextField!
    @IBOutlet weak var _checkbox: UIButton!
    let alertFunctions: AlertFunctions = AlertFunctions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func RegisterPressed(_ sender: UIButton) {
        
        let fullname = _fullname.text
        let username = _username.text
        let password = _password.text
        let email = _email.text
        let mobileNumber = _mobileNumber.text
        
        if (fullname == "" || username == "" || password == "" || email == "" || mobileNumber == "") {
            
            self.alertFunctions.showAlert(self, "Error", msg: "Please fill all fields")
            return
            
        }
        
        if (!_checkbox.isSelected){
            
            self.alertFunctions.showAlert(self, "Error", msg: "Please agree to the terms and conditions")
            return
        }
        
        DoRegister(fullname!, username!, password! ,email!, mobileNumber!)
        
    }
    
    func DoRegister(_ full_name:String,_ user_name:String,_ pass:String ,_ email:String,_ mobile_number:String){
        
        let url = URL(string: "http://localhost:8888/test_db/index.php/")
        
        let paramToSend = "username=" + user_name +
                          "&password=" + pass +
                          "&email=" + email +
                          "&fullname=" + full_name +
                          "&mobileNumber=" + mobile_number
        
        let sendRequest:HTTPFunctions = HTTPFunctions()
        sendRequest.POST(url!, paramToSend) { response in
            
            if let session_data = response["success"] as? Int {
               
                if session_data == 0 {
                    //TODO: Handle having an invalid email address
                    self.alertFunctions.showAlert(self, "Error in registering", msg: "Username/Email already exists")
                    return
                }
                
                let info = response.value(forKey: "info") as! NSDictionary
                let userId = info.value(forKey: "id")
                print(userId!)
//                let userId = info.value(forKey: "id")
                
                
                //Navigating user to the login page
                let doAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                let loggedInVC = self.storyboard?.instantiateViewController(withIdentifier: "LoggedInViewController")
                self.present(loggedInVC!, animated: true, completion: nil)}
                self.alertFunctions.showActionAlert(self, "Success", "You have been registered successfully.", doAction)
            }
        }
    }
    

    @IBAction func checkBoxTapped(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = false
        }else {
            sender.isSelected = true
        }
    }
}

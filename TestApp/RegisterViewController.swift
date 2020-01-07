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
    var user:Person = Person()
    let preferences = UserDefaults.standard
   
    
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
                
                guard let info = response.value(forKey: "info") as? NSDictionary else {
                    
                    self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                    return
                }
                
                guard let userId = info.value(forKey: "id") as? Int else {
                        
                    self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                    return
                }
                
                //Setting user data
                self.user.setUserId(userId)
                self.user.setFullName(full_name)
                self.user.setUsername(user_name)
                self.user.setPassword(pass)
                self.user.setEmail(email)
                self.user.setMobileNumber(mobile_number)
                                            
                //Saving data to preferences
                self.preferences.set(userId, forKey: "userId")
                self.preferences.set(full_name, forKey: "fullName")
                self.preferences.set(user_name, forKey: "username")
                self.preferences.set(email, forKey: "email")
                self.preferences.set(mobile_number, forKey: "mobileNumber")
                                    
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

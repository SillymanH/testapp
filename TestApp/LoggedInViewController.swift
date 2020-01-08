//
//  LoggedInViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/23/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import UIKit

class LoggedInViewController: UIViewController {

    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _login_button: UIButton!
    let alertFunctions: AlertFunctions = AlertFunctions()
    let user:Person = Person()
    let preferences = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (preferences.object(forKey: "session") != nil)
        {
            LoginDone()
            preferences.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            preferences.synchronize()
        }
        else
        {
            LoginToDo()
        }
    }
    
    @IBAction func LoginPressed(_ sender: Any) {
        if(_login_button.titleLabel?.text == "Logout")
        {
            preferences.removeObject(forKey: "session")
                
            LoginToDo()
            return
        }
        
        let username = _username.text
        let password = _password.text
            
        if(username == "" || password == "")
        {
            alertFunctions.showAlert(self, "Error", msg: "Please fill all fields")
            return
        }
        DoLogin(username!, password!)
    }
    
    func DoLogin(_ user:String, _ psw:String) {
        let url = URL(string: "http://localhost:8888/test_db/index.php/")
        
        let paramToSend = "username=" + user +
                          "&password=" + psw
        
        let httpRequest: HTTPFunctions = HTTPFunctions()
        httpRequest.POST(url!, paramToSend){ Response in
            
            guard let session_data = Response["success"] as? Int else{
                
                self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                return
            }
            
            if session_data == 0 {
                
                self.alertFunctions.showAlert(self ,"Invalid Login", msg: "Wrong username or password")
                    return
            }
            
            if let info = Response["info"] as? NSDictionary  {
                
                let userId = (info.value(forKey: "id") as? NSString)?.integerValue
                let user_name = info.value(forKey: "username") as? String
                let email = info.value(forKey: "email") as? String
                let full_name = info.value(forKey: "fullname") as? String
                let mobile_number = info.value(forKey: "mobileNumber") as? String
                
                //Setting user data
                self.user.setUserId(userId!)
                self.user.setFullName(full_name!)
                self.user.setUsername(user_name!)
                self.user.setEmail(email!)
                self.user.setMobileNumber(mobile_number!)
                
                //Saving data to preferences
                self.preferences.set(userId, forKey: "userId")
                self.preferences.set(full_name, forKey: "fullName")
                self.preferences.set(user_name, forKey: "username")
                self.preferences.set(email, forKey: "email")
                self.preferences.set(mobile_number, forKey: "mobileNumber")
                
                self.preferences.set(session_data, forKey: "session")
                DispatchQueue.main.async {
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "landing_page") as! ViewController
                self.present(newViewController, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func LoginToDo() {
        
          _username.isEnabled = true
          _password.isEnabled = true
          
          _login_button.setTitle("Login", for: .normal)
    }
    
    func LoginDone() {
        
          _username.isEnabled = false
          _password.isEnabled = false
          
          _login_button.setTitle("Logout", for: .normal)
        
    }
        
}

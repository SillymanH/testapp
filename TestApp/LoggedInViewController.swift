//
//  LoggedInViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/23/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class LoggedInViewController: UIViewController , LoginButtonDelegate {
   

    
    //Outlets
    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _login_button: UIButton!
    @IBOutlet weak var rememberMeCheckbox: UIButton!
    @IBOutlet weak var gLoginButton: GIDSignInButton!
    
    // APIs
    let loginURL = "http://localhost:8888/test_db/index.php/"
    
    //Global Instances
    let alert: AlertFunctions = AlertFunctions()
    let httpRequest: HTTPFunctions = HTTPFunctions()
    var user:Person = Person()
    
    //Global Variables
    let preferences = UserDefaults.standard
    var fbLoginButton = FBLoginButton()
    let loginManager = LoginManager()
//    var gLoginButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (preferences.object(forKey: "session") != nil || AccessToken.current != nil) {
            
            LoginDone()
//            preferences.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//            preferences.synchronize()
            
        }else { LoginToDo() }
    }
    
    func fetchUserFBData() {
        
        let params = ["fields": "email"]
        GraphRequest(graphPath: "me", parameters: params).start {
            (graphConnection, response, error) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            let NSresponse = response as? NSDictionary
            if let email = NSresponse!["email"] as? String {
                
                self.user.setEmail(email)
                
                let isLoginSuccessful = self.DoLogin("", "")
                if isLoginSuccessful {
                   
                    self.LoginDone()
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                    
                } else {
                    self.LoginToDo()
                }
            }
            
            print(response!)
        }
    }
    
    func createFBLoginButton() {
        
        fbLoginButton.delegate = self
        fbLoginButton.center = view.center
        view.addSubview(fbLoginButton)
        fbLoginButton.permissions.append("email")
    }
    
    func createGoogleLoginButton() {
        
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
//        gLoginButton.center = view.center
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
           print("Completed Login")
           fetchUserFBData()
       }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }

    func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
        return true
    }
    
    
    @IBAction func LoginPressed(_ sender: Any) {
        
        if(_login_button.titleLabel?.text == "Logout")
        {
            preferences.removeObject(forKey: "session")
            loginManager.logOut()
            GIDSignIn.sharedInstance().signOut()
            LoginToDo()
            return
        }
        
        let username = _username.text
        let password = _password.text
            
        if(username == "" || password == "")
        {
            alert.showAlert(self, "Error", msg: "Please fill all fields")
            return
        }
        
        if(rememberMeCheckbox.isSelected) {
            
            preferences.set(username, forKey: "username") //save username if remember me checkbox is checked
        }else {
            
            if (preferences.object(forKey: "username") != nil) {
                
                preferences.removeObject(forKey: "username")
            }
        }
        
        let isLoginSuccessful = DoLogin(username!, password!)
        if isLoginSuccessful {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    func DoLogin(_ user:String, _ psw:String) -> Bool {
        
        var paramToSend = ""
        if (user == "" && psw == "") {
            
            paramToSend = "username=&password=&email=" + self.user.getEmail()
        }else {
            
            paramToSend = "username=\(user)&password=\(psw)&email="
        }
        let httpMethod = "POST"
        
        
        var success = false
        self.httpRequest.DoRequestReturnJSON(self.loginURL, paramToSend, httpMethod, CustomRequest: nil) { json in
            
            
            guard let response = json as? NSDictionary else {
                
                success = false
                self.alert.showAlert(self, "Error", msg: "Something went wrong!")
                    return
            }
            
            guard ((response["success"] as? Int) == 1) else {
                
                success = false
                self.alert.showAlert(self ,"Error", msg: "Invalid Login")
                    return
            }
            
            if let info = response["info"] as? NSDictionary  {
                
                self.preferences.set(response, forKey: "session") //Setting session
                
                let userId = (info.value(forKey: "id") as? NSString)?.integerValue
                let user_name = info.value(forKey: "username") as? String
                let full_name = info.value(forKey: "fullname") as? String
                let mobile_number = info.value(forKey: "mobileNumber") as? String
                
                //Setting user data
                self.user.setUserId(userId!)
                self.user.setFullName(full_name!)
                self.user.setUsername(user_name!)
                self.user.setMobileNumber(mobile_number!)
                
                guard let email = info.value(forKey: "email") as? String else {
                    
                    success = true
                    return
                }
                self.user.setEmail(email) //Setting email if returned by response
                success = true
            }
        }
        return success
    }
    
    func LoginToDo() {
        
        _username.isEnabled = true
        _username.text = preferences.object(forKey: "username") as? String
        _password.isEnabled = true
        _login_button.setTitle("Login", for: .normal)
        
        if preferences.bool(forKey: "rememberMe") {
            rememberMeCheckbox.isSelected = true
        }
        createFBLoginButton()
        createGoogleLoginButton()
    }
    
    func LoginDone() {
        
          _username.isEnabled = false
          _password.isEnabled = false
          _login_button.setTitle("Logout", for: .normal)
    }
    
    @IBAction func rememberMeCheckboxChecked(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = false
        }else {
            sender.isSelected = true
        }
        preferences.set(sender.isSelected, forKey: "rememberMe") //Saving the state of the remember me checkbox
    }
    
        
}

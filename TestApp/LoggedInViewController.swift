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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let preferences = UserDefaults.standard
        
        if(preferences.object(forKey: "session") != nil)
        {
            LoginDone()
        }
        else
        {
            LoginToDo()
        }
    }
    
    @IBAction func LoginPressed(_ sender: Any) {
        if(_login_button.titleLabel?.text == "Logout")
               {
                   let preferences = UserDefaults.standard
                   preferences.removeObject(forKey: "session")
                   
                   LoginToDo()
                   return
               }
               
               
               let username = _username.text
               let password = _password.text
               
               if(username == "" || password == "")
               {
                   return
               }
               
               DoLogin(username!, password!)
    }
    
    func DoLogin(_ user:String, _ psw:String)
       {
           let url = URL(string: "http://www.kaleidosblog.com/tutorial/login/api/login")
           let session = URLSession.shared
           
           let request = NSMutableURLRequest(url: url!)
           request.httpMethod = "POST"
           
           let paramToSend = "username=" + user + "&password=" + psw
           
           request.httpBody = paramToSend.data(using: String.Encoding.utf8)
           
           
           let task = session.dataTask(with: request as URLRequest, completionHandler: {
           (data, response, error) in
               
               guard let _:Data = data else
               {
                   return
               }
               
               let json:Any?
               
               do
               {
                   json = try JSONSerialization.jsonObject(with: data!, options: [])
               }
               catch
               {
                   return
               }
               
               
               guard let server_response = json as? NSDictionary else
               {
                   return
               }
               
               
               if let data_block = server_response["data"] as? NSDictionary
               {
                   if let session_data = data_block["session"] as? String
                   {
                       let preferences = UserDefaults.standard
                       preferences.set(session_data, forKey: "session")
                       
                       DispatchQueue.main.async (
                           execute:self.LoginDone
                       )
                   }
               }
           
           })
           
           task.resume()
       }
    
    func LoginToDo()
    {
          _username.isEnabled = true
          _password.isEnabled = true
          
          _login_button.setTitle("Login", for: .normal)
        
    }
    
    func LoginDone()
    {
          _username.isEnabled = false
          _password.isEnabled = false
          
          _login_button.setTitle("Logout", for: .normal)
        
    }

}

//
//  ForgotMyPasswordViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 2/20/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import UIKit

class ForgotMyPasswordViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    
    let alert = AlertFunctions()
    let http = HTTPFunctions()
    
    let sendOTP_API = "http://localhost:8888/test_db/SendOTP.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func SendVerificationCodePressed(_ sender: UIButton) {
        
        if email.text!.isEmpty {
            
            alert.showAlert(self, "Error", msg: "Please fill all fields")
                return
        }
        
        let params = "email=" + self.email.text!
        http.DoRequestReturnJSON(sendOTP_API, params, "POST", CustomRequest: nil) { json in
            
            guard let response = json as? NSDictionary else {
                
                self.alert.showAlert(self, "Error", msg: "Something went wrong!")
                    return
            }
            guard ((response["success"] as? Int) == 1) else {
                
                self.alert.showAlert(self ,"Error", msg: response["info"] as! String)
                    return
            }
        }
        DispatchQueue.main.async {
            
            let OTPViewController = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController")
            self.present(OTPViewController!, animated: true, completion: nil)
        }
    }
}


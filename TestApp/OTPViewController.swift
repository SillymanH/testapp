//
//  OTPViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 2/20/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import UIKit

class OTPViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var otpField1: UITextField!
    @IBOutlet weak var otpField2: UITextField!
    @IBOutlet weak var otpField3: UITextField!
    @IBOutlet weak var otpField4: UITextField!
    
    let alert = AlertFunctions()
    let http = HTTPFunctions()
    
    let verifyOTP_API = "http://localhost:8888/test_db/VerifyOTP.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        otpField1.delegate = self
        otpField2.delegate = self
        otpField3.delegate = self
        otpField4.delegate = self
        
        otpField1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpField2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpField3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpField4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(textField: UITextField){

        let text = textField.text

        if text!.count >= 1 {
            
            switch textField{
                
            case otpField1:
                otpField2.becomeFirstResponder()
                
            case otpField2:
                otpField3.becomeFirstResponder()
                
            case otpField3:
                otpField4.becomeFirstResponder()
                
            case otpField4:
                otpField4.resignFirstResponder()
                
            default:
                break
            }
        }else{

        }
    }
    
    @IBAction func SubmitBtnPressed(_ sender: UIButton) {
        
        if otpField1.text!.isEmpty || otpField2.text!.isEmpty || otpField3.text!.isEmpty || otpField4.text!.isEmpty {
            
            alert.showAlert(self, "Error", msg: "Please fill all fields")
                return
        }
        
        let params = "otp=\(otpField1.text!)\(otpField2.text!)\(otpField3.text!)\(otpField4.text!)"
        http.DoRequestReturnJSON(verifyOTP_API, params, "POST", CustomRequest: nil) { json in
            
            guard let response = json as? NSDictionary else {
                
                self.alert.showAlert(self, "Error", msg: "Something went wrong!")
                    return
            }
            guard ((response["success"] as? Int) == 1) else {
                
                self.alert.showAlert(self ,"Error", msg: response["info"] as! String)
                    return
            }
            
        }
    }
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      var result = true
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            result = false
            return result
        }
        
        let disallowedCharacterSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let isNumeric = string.rangeOfCharacter(from: disallowedCharacterSet) == nil //Checking if characters are numeric
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        let isSingleDigit = updateText.count <= 1 //Checking if the number of characters is <= 1
        
        if !(isNumeric && isSingleDigit) {
             result = false
        }
        return result
    }


}

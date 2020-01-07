//
//  Person.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/6/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import Foundation

class Person {
    
    private var userId: Int
    private var username: String
    private var password: String
    private var email: String
    private var fullname:String
    private var mobileNumber:String
    
    init(_ userId:Int,_ username:String,_ password: String,_ email:String,
                                        _ fullname:String,_ mobileNumber:String) {
        
        self.userId = userId
        self.username = username
        self.password = password
        self.email = email
        self.fullname = fullname
        self.mobileNumber = mobileNumber
    }
    
    //Getters
        
    public func getUserId() -> Int {
        
        return self.userId
    }
    
    public func getUsername() -> String {
        
        return self.username
    }
    
    public func getPassword() -> String {
           
           return self.password
       }
    
    public func getEmail() -> String {
           
           return self.email
       }
    
    public func getFullName() -> String {
           
           return self.fullname
       }
    
    public func getMobileNumber() -> String {
           
           return self.mobileNumber
       }
    
    // Setters
    
    public func setUserId(_ userId:Int) {
           
        self.userId = userId
       }
    
    public func setUsername(_ username:String) {
        
     self.username = username
    }
    
    public func setPassword(_ password:String) {
        
     self.password = password
    }
    
    public func setEmail(_ email:String) {
        
     self.email = email
    }
    
    public func setFullName(_ fullname:String) {
        
     self.fullname = fullname
    }
    
    public func setMobileNumber(_ mobileNumber:String) {
        
     self.mobileNumber = mobileNumber
    }
}

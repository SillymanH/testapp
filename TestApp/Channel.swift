//
//  Channel.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/22/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import Foundation

class Channel {
    
    //Properties
    private var channelOwnerId = 0
    private var channelId = 0
    private var channelName = ""
    private var channelURL = ""
    private var subscribers = 0
    private var dateCreated = ""
    private var coverPhotoURL = ""
    private var profilePhotoURL = ""
    
    //APIs
    let channelInfoAPI = "http://localhost:8888/test_db/Channels.php/"
    
    //Global Instances
    var http:HTTPFunctions = HTTPFunctions()
    var alert:AlertFunctions = AlertFunctions()
    
    init() {}
    
    //Setters
    
    public func setChannelOwnderId(_ channelOwnerId:Int) {
        
        self.channelOwnerId = channelOwnerId
    }
    
    public func setChannelId(_ channelId:Int) {
           
           self.channelId = channelId
       }
    
    public func setChannelName(_ channelName:String) {
        
        self.channelName = channelName
    }
    
    public func setChannelURL(_ channelURL:String) {
        
        self.channelURL = channelURL
    }
    
    public func setSubscribers(_ subscribers:Int) {
        
        self.subscribers = subscribers
    }
    
    public func setDateCreated(_ dateCreated:String) {
           
           self.dateCreated = dateCreated
       }
    
    public func setCoverPhotoURL(_ url:String) {
        self.coverPhotoURL = url
    }
    
    public func setProfilePhotoURL(_ url:String) {
        self.profilePhotoURL = url
    }
    
    // Getters
    
    public func getChannelOwnderId() -> Int {
        
        return self.channelOwnerId
    }
    
    public func getChannelId() -> Int {
        
        return self.channelId
    }
    
    public func getChannelName() -> String {
        
        return self.channelName
    }
    
    public func getChannelUrl() -> String {
        
        return self.channelURL
    }
    
    public func getSubscribers() -> Int {
        
        return self.subscribers
    }
    
    public func getDateCreated() -> String {
        
        return self.dateCreated
    }
    
    public func getCoverPhotoURL() -> String {
        return self.coverPhotoURL
    }
    
    public func getProfilePhotoURL() -> String {
        return self.profilePhotoURL
    }
    
    func getChannelInfo(_ channelId:Int) {
           
           let paramToSend = "channel_id=\(channelId)"
           let httpMethod = "GET"
           
           http.DoRequestReturnJSON(self.channelInfoAPI, paramToSend, httpMethod, CustomRequest: nil) { json in
               
               guard let response = json as? NSDictionary else {
                   
                   self.alert.showAlert(self, "Error", msg: "Something went wrong!")
                       return
               }
               
               guard ((response["success"] as? Int) == 1) else {
                   
                   self.alert.showAlert(self ,"Error", msg: "Could not get channel info")
                       return
               }
               
               if let channelData = response["info"] as? NSDictionary {
                   
                   let channelOwnerId = (channelData.value(forKey: "user_id") as? NSString)?.integerValue
                   let channelId = (channelData.value(forKey: "channel_id") as? NSString)?.integerValue
                   let channelName = channelData.value(forKey: "channel_name") as? String
                   let subscribers = (channelData.value(forKey: "channel_subscribers_number") as? NSString)?.integerValue
                   let dateCreated = channelData.value(forKey: "date_created") as? String
                   let coverPhotoURL = channelData.value(forKey: "cover_photo_url") as? String
                   let profilePhotoURL = channelData.value(forKey: "profile_photo_url") as? String
                   
                self.setChannelOwnderId(channelOwnerId!)
                self.setChannelId(channelId!)
                self.setChannelName(channelName!)
                self.setSubscribers(subscribers!)
                self.setDateCreated(dateCreated!)
                self.setCoverPhotoURL(coverPhotoURL!)
                self.setProfilePhotoURL(profilePhotoURL!)
            }
        }
    }
}

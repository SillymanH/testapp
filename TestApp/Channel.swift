//
//  Channel.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/22/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import Foundation

class Channel {
    
    private var channelOwnerId = 0
    private var channelId = 0
    private var channelName = ""
    private var channelURL = ""
    private var subscribers = 0
    private var dateCreated = ""
    private var coverPhotoURL = ""
    private var profilePhotoURL = ""
    
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
    
}

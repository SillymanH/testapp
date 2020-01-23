//
//  ChannelViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/22/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import UIKit

class ChannelViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Outlets
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var subscriberNumber: UILabel!
    
    //API
    let channelInfoURL = "http://localhost:8888/test_db/Channels.php"
    
    //Global Instances
    let http:HTTPFunctions = HTTPFunctions()
    let alert:AlertFunctions = AlertFunctions()
    let channel:Channel = Channel()
    let youtube:YoutubeFunctions = YoutubeFunctions()
    
    //Global Variables
    var imagePicker: ImagePicker!
    var isCoverUpload:Bool = false // This flag is to determine if user wants to upload a cover or a profile
    var video:Video = Video()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getChannelInfo()
        
        let channelName = self.channel.getChannelName()
        let subscribers = self.channel.getSubscribers()
        
        
        channelNameLabel?.text = channelName
        subscriberNumber?.text = "\(self.youtube.statCheck(subscribers)) subscribers"
        
    }
    
    @IBAction func CoverPhotoUploadBtnPressed(_ sender: UIButton) {
        
        self.isCoverUpload = true
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func ProfileImageUploadBtnPressed(_ sender: UIButton) {
        
        self.isCoverUpload = false
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func SubscribePressed(_ sender: UIButton) {
        
    }
    
    func getChannelInfo() {
        
        let channelId = self.video.getChannelId()
        
        let paramToSend = "channel_id=\(channelId)"
        let httpMethod = "GET"
        
        http.doRequest(self.channelInfoURL, paramToSend, httpMethod) { response in
            
            guard let data = response["success"] as? Int else {
                
                self.alert.showAlert(self, "Error", msg: "Something went wrong!")
                    return
            }
            
             if data == 0 {
                
                self.alert.showAlert(self ,"Error", msg: "Could not get channel info")
                    return
            }
            
            
            if let channelData = response["info"] as? NSDictionary {
                
                let channelOwnerId = (channelData.value(forKey: "user_id") as? NSString)?.integerValue
                let channelId = (channelData.value(forKey: "channel_id") as? NSString)?.integerValue
                let channelName = channelData.value(forKey: "channel_name") as? String
                let subscribers = (channelData.value(forKey: "channel_subscribers_number") as? NSString)?.integerValue
                let dateCreated = channelData.value(forKey: "date_created") as? String
                
                self.channel.setChannelOwnderId(channelOwnerId!)
                self.channel.setChannelId(channelId!)
                self.channel.setChannelName(channelName!)
                self.channel.setSubscribers(subscribers!)
                self.channel.setDateCreated(dateCreated!)
                
            }
        }
    }
}

extension ChannelViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        
        if self.isCoverUpload {
            
            self.coverPhoto.image = image
        }else {
            
             self.profileImage.image = image
        }
        
    }
}

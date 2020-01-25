//
//  ChannelViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/22/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import UIKit

protocol passVideoToDisplayDelegate {
    func passYouTubeId(id:String)
}

class ChannelViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //Outlets
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var subscriberNumber: UILabel!
    @IBOutlet weak var channelVideosTable: UITableView!
    
    //API
    let channelInfoURL = "http://localhost:8888/test_db/Channels.php"
    let videosAPI = "http://localhost:8888/test_db/Videos.php/"
    
    //Global Instances
    let http:HTTPFunctions = HTTPFunctions()
    let alert:AlertFunctions = AlertFunctions()
    let channel:Channel = Channel()
    let youtube:YoutubeFunctions = YoutubeFunctions()
    
    //Global Variables
    var imagePicker: ImagePicker!
    var isCoverUpload:Bool = false // This flag is to determine if user wants to upload a cover or a profile
    var video:Video = Video()
    var channelVideos: [NSDictionary] = []
    var youtubeIds:[String] = []
    var delegate: passVideoToDisplayDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getChannelInfo()
        let channelName = self.channel.getChannelName()
        let subscribers = self.channel.getSubscribers()
        let channelId = self.channel.getChannelId()
        self.channelVideos = getChannelVideos(channelId)
        
        
        channelNameLabel?.text = channelName
        subscriberNumber?.text = "\(self.youtube.statCheck(subscribers)) subscribers"
        reloadVideoTable()
        
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
    
    func reloadVideoTable(){
        
        channelVideosTable.dataSource = self
        channelVideosTable.delegate = self
        channelVideosTable.reloadData()  
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channelVideos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let videoTitle = self.video.getSpecificVideoData(self.channelVideos, attribut: "video_title")
        
        let cell : SuggestedVideosCell = tableView.dequeueReusableCell(withIdentifier: "allVideosCell") as! SuggestedVideosCell
        cell.allVideosLabel?.text = videoTitle[indexPath.row]
        
        self.youtubeIds = self.video.getSpecificVideoData(self.channelVideos, attribut: "youtube_video_id")
        
        DispatchQueue.main.async {
            
            self.youtube.prepYoutubeView(self.youtubeIds[indexPath.row], cell.allVideosWebView, self)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard youtubeIds[indexPath.row] != "" else {
            
            self.alert.showAlert(self, "Error", msg: "Something went wrong!")
                return
        }
        
        delegate?.passYouTubeId(id: youtubeIds[indexPath.row])
    }
    
    func getChannelVideos(_ channelId:Int) -> [NSDictionary]{
        
        var videosData:[NSDictionary] = []
            
            let paramToSend = "channel_id=\(channelId)"
            let httpMethod = "POST"
            
            self.http.doRequest(self.videosAPI, paramToSend, httpMethod, CustomRequest: nil) { json in
        
                guard let response = json as? NSDictionary else {
                    
                    self.alert.showAlert(self, "Error", msg: "Something went wrong!")
                        return
                }
                
                guard ((response["success"] as? Int) == 1) else {
                    
                    self.alert.showAlert(self ,"Error", msg: "Could not get channel info")
                        return
                }
                
                if let videos = response["info"] as? [Any] {
                    
                    for video in videos {
                        videosData.append(video as! NSDictionary)
                    }
                 }
            }
            return videosData
    }
    
    func getChannelInfo() {
        
        let channelId = self.video.getChannelId()
        
        let paramToSend = "channel_id=\(channelId)"
        let httpMethod = "GET"
        
        http.doRequest(self.channelInfoURL, paramToSend, httpMethod, CustomRequest: nil) { json in
            
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

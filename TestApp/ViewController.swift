//
//  ViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/22/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITableViewDelegate, UITableViewDataSource {

    //Outlets
    @IBOutlet weak var youTubeWebView: WKWebView!
    @IBOutlet weak var suggestedVideosTable: UITableView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var numberOfDislikesLabel: UILabel!
    @IBOutlet weak var NumberofSharesLabel: UILabel!
    @IBOutlet weak var numberOfDownloadsLabel: UILabel!
    @IBOutlet weak var numberOfSavesLabel: UILabel!
    
    
    //APIs
    let interactionAPI = URL(string: "http://localhost:8888/test_db/Interactions.php/")
    let videosAPI = URL(string: "http://localhost:8888/test_db/Videos.php/")
    
    //Global Instances
    let youtube:YoutubeFunctions = YoutubeFunctions()
    let http:HTTPFunctions = HTTPFunctions();
    var video:Video = Video()
    let alertFunctions:AlertFunctions = AlertFunctions()
    var login:LoggedInViewController = LoggedInViewController()
    
    //Global Variables
    var suggestedVideos: [NSDictionary] = []
    let preferences = UserDefaults.standard
    var interaction:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.suggestedVideos = getVideos(10)
        let firstIndexedVideo = suggestedVideos[0]
        let youtubeId = firstIndexedVideo["youtube_video_id"]
        reloadVideoView(youtubeVideoId: youtubeId as! String)
        reloadVideoTable()
    }

    func reloadVideoView(youtubeVideoId:String) {
    
        let paramToSend = "youtubeVideoId=\(youtubeVideoId)"
        self.http.POST(self.videosAPI!, paramToSend) { response in
            
            guard let session_data = response["success"] as? Int else {
            
                self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                    return
            }
            
            if session_data == 0 {
                
                self.alertFunctions.showAlert(self ,"Error", msg: "Could not load video!")
                    return
            }
            
            if let info = response["info"] as? NSDictionary  {
                
                let videoId = (info.value(forKey: "video_id") as? NSString)?.integerValue
                let channelId = (info.value(forKey: "channel_id") as? NSString)?.integerValue
                let videoLikes = (info.value(forKey: "video_likes") as? NSString)?.integerValue
                let videoDislikes = (info.value(forKey: "video_dislikes") as? NSString)?.integerValue
                let videoShares = (info.value(forKey: "video_shares") as? NSString)?.integerValue
                let videoDownloads = (info.value(forKey: "video_downloads") as? NSString)?.integerValue
                let videoSaves = (info.value(forKey: "video_saves") as? NSString)?.integerValue
                let videoTitle = info.value(forKey: "video_title") as? String

                //Setting video info
                self.video.setVideoId(videoId!)
                self.video.setChannelId(channelId!)
                self.video.setVideoLikes(videoLikes!)
                self.video.setVideoDislikes(videoDislikes!)
                self.video.setVideoShares(videoShares!)
                self.video.setVideoDownloads(videoDownloads!)
                self.video.setVideoSaves(videoSaves!)
                self.video.setVideoTitle(videoTitle!)
                self.video.setYoutubeId(youtubeVideoId)
            }
            
            DispatchQueue.main.async {
                
                self.youtube.prepYoutubeView(youtubeVideoId, self.youTubeWebView, classInstance: self)
                self.videoTitleLabel?.text = "\(self.video.getVideoTitle())"
                
                let likes = self.video.getVideoLikes()
                let dislikes = self.video.getVideoDislikes()
                let shares = self.video.getVideoShares()
                let downloads = self.video.getVideoDownloads()
                let saves = self.video.getVideoSaves()
                self.numberOfLikesLabel?.text = self.statCheck(likes)
                self.numberOfDislikesLabel?.text = self.statCheck(dislikes)
                self.NumberofSharesLabel?.text = self.statCheck(shares)
                self.numberOfDownloadsLabel?.text = self.statCheck(downloads)
                self.numberOfSavesLabel?.text = self.statCheck(saves)
                
            }
        }

    }
    
    func statCheck(_ statNumber:Int) -> String {
        
        var statStr:String = "\(statNumber)"
        
        if statNumber >= 1000 && statNumber < 1000000 {
            
           statStr = "\(statNumber / 1000)K"
        }
        
        if statNumber >= 1000000 && statNumber < 1000000000 {
            
           statStr = "\(statNumber / 1000000)M"
        }
        
        if statNumber >= 1000000000 && statNumber < 1000000000000 {
            
           statStr = "\(statNumber / 10000000)T"
        }
        
        return statStr
    }
    
    func reloadVideoTable(){
        
        suggestedVideosTable.dataSource = self
        suggestedVideosTable.delegate = self
        suggestedVideosTable.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.suggestedVideos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let videoTitle = self.video.getSpecificVideoData(self.suggestedVideos, attribut: "video_title")
        
        let cell : SuggestedVideosCell = tableView.dequeueReusableCell(withIdentifier: "suggested_videos_cell") as! SuggestedVideosCell
        cell.suggestedVideosLabel?.text = videoTitle[indexPath.row]
        
        let youtubeIds = self.video.getSpecificVideoData(self.suggestedVideos, attribut: "youtube_video_id")
        
        DispatchQueue.main.async {
            
            self.youtube.prepYoutubeView(youtubeIds[indexPath.row], cell.suggestedVideoWebView,
                                         classInstance: self)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let youtubeIds = video.getSpecificVideoData(self.suggestedVideos, attribut: "youtube_video_id")
        reloadVideoView(youtubeVideoId: youtubeIds[indexPath.row])
    }
    
    func isSessionStored() -> Bool {
        
        if (preferences.object(forKey: "session") == nil){
            return false
        }
        return true
    }
    
    @IBAction func LikeIconPressed(_ sender: UIButton) {
        
        self.interaction = 1 // interaction = 1 means LIKE interactino
        var action:String = "SET_INTERACTION"
        
        if (!isInteractionBtnClicked(sender)) {
            
            action = "UNSET_INTERACTION"
        }
           
        if isSessionStored() {
            doInteraction(action: action, interaction: self.interaction)
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true)
        }
    }
    
    @IBAction func DislikeIconPressed(_ sender: UIButton) {
        
        self.interaction = 2 // interaction = 2 means Dislike interaction
        var action:String = "SET_INTERACTION"
        
        if (!isInteractionBtnClicked(sender)) {
            
            action = "UNSET_INTERACTION"
        }
        
        if isSessionStored() {
            doInteraction(action: action, interaction: self.interaction)
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true, completion: nil)
        }
    }
    
    @IBAction func ShareIconPressed(_ sender: UIButton) {
        
        self.interaction = 3 // interaction = 3 means SHARE interaction
        
        if isSessionStored() {
            
            let youtubeIds = self.video.getSpecificVideoData(self.suggestedVideos, attribut: "youtube_video_id")
            let url = "http://www.youtube.com/embed/\(youtubeIds[0])"
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityController, animated: true, completion: nil)
            
            let action = "SHARE"
            doInteraction(action: action, interaction: self.interaction)
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true, completion: nil)
            
            
        }
    }
    
    @IBAction func DownloadIconPressed(_ sender: UIButton) {
        
        self.interaction = 4 // interaction = 4 means DOWNLOAD interaction
        
        if isSessionStored() {
            
            let youtubeIds = self.video.getSpecificVideoData(self.suggestedVideos, attribut: "youtube_video_id")
            let url = "http://www.youtube.com/embed/\(youtubeIds[0])"
            
//            guard (isInteractionBtnClicked(sender)) else {
//
//                let doAction = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
//
//                    //TODO: Remove video from downloads
//
//                }
//                self.alertFunctions.showActionAlert(self, "Warning", "Are you sure you want to delete this video from downloads?", doAction)
//                return
//            }
            http.Download(url) { response in

                guard (response) else {

                    self.alertFunctions.showAlert(self, "Error", msg: "Could not download video")
                        return
                }
                self.alertFunctions.showAlert(self, "Success", msg: "Download Completed")
            }
            
            let action = "DOWNLOAD"
            doInteraction(action: action, interaction: self.interaction)
            
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true, completion: nil)
        }
    }
    
    @IBAction func SaveIconPressed(_ sender: UIButton) {
        
        self.interaction = 5 // interaction = 5 means SAVE interaction
        
        if isSessionStored() {
            
            //TODO: Implement the SAVE functionality
            let action = "SAVE"
            doInteraction(action: action, interaction: self.interaction)
            
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true, completion: nil)
        }
    }
    
    func doInteraction(action:String, interaction:Int) {
        
       
        
        //Getting User info
        let userId =  preferences.integer(forKey: "userId")
        
        //Getting video info
        let videoId = self.video.getVideoId()
        let youtubeVideoId = self.video.getYouTubeId()
                                    
        let paramToSend = "userId=\(userId)" +
                          "&videoId=\(videoId)" +
                          "&videoURL=\(youtubeVideoId)" +
                          "&interaction=\(self.interaction)" +
                          "&action=\(action)"
        
        self.http.POST(self.interactionAPI!, paramToSend){ response in
            
            guard let session_data = response["success"] as? Int else{
                
//                if (action == "SET_INTERACTION" || action == "UNSET_INTERACTION")
                self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                    return
            }
            
            if session_data == 0 {
                
                //TODO: Handle having an invalid email address
                self.alertFunctions.showAlert(self, "Error", msg: "Could not set interaction!")
                    return
            }
        }
    }
    
    func getVideos(_ numberOfVideos:Int) -> [NSDictionary] {
        
        var videosData:[NSDictionary] = []
        
        let paramToSend = "numberOfVideos=\(numberOfVideos)"
        
        self.http.POST(self.videosAPI!, paramToSend) { response in
    
            guard let session_data = response["success"] as? Int else{
                
                self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                return
            }
            
            if session_data == 0 {
                
                self.alertFunctions.showAlert(self ,"Error", msg: "Could not load videos!")
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
    
    private func isInteractionBtnClicked(_ button:UIButton) -> Bool {
        
        if (button.isSelected){
            button.isSelected = false
        } else {
            button.isSelected = true
        }
        return button.isSelected
    }
}


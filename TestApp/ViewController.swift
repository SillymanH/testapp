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
    
    //APIs
    let interactionAPI = URL(string: "http://localhost:8888/test_db/Interactions.php/")
    let randomVideosAPI = URL(string: "http://localhost:8888/test_db/Videos.php/")
    let videosAPI = URL(string: "http://localhost:8888/test_db/Videos.php/")
    
    //Global Instances
    let youtube:YoutubeFunctions = YoutubeFunctions()
    let http:HTTPFunctions = HTTPFunctions();
    var video:Video = Video()
    let alertFunctions: AlertFunctions = AlertFunctions()
    var login:LoggedInViewController = LoggedInViewController()
    
    //Global Variables
    var videoArray:Array<String> = []
    let preferences = UserDefaults.standard
    var interaction:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        reloadVideoView()
        reloadVideoTable()
    }

    func reloadVideoView() {
        
        self.videoArray = getRandomVideos(6)
    
        let youtubeVideoId = self.videoArray[0]
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
                
                self.youTubeWebView.navigationDelegate = self
                self.youTubeWebView.configuration.allowsInlineMediaPlayback = false
                self.youtube.loadYoutubeIframe(youtubeVideoId, self.youTubeWebView) //Loading video on the video view using youtube id
            }
        }

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
        return videoArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SuggestedVideosCell = tableView.dequeueReusableCell(withIdentifier: "suggested_videos_cell") as! SuggestedVideosCell
        cell.suggestedVideosLabel.text = videoArray[indexPath.row]
            return cell
    }
    
    func isSessionStored() -> Bool {
        
        if (preferences.object(forKey: "session") == nil){
            return false
        }
        return true
    }
    
    @IBAction func LikeIconPressed(_ sender: UIButton) {
        
        self.interaction = 1
        let action:String = isInteractionBtnClicked(sender)
           
        if isSessionStored() {
            
            //Getting User info
            let userId =  preferences.integer(forKey: "userId")
  
            //Getting video info
            let videoId = self.video.getVideoId()
            let youtubeVideoId = self.video.getYouTubeId()
            
            let paramToSend = "userId=\(userId)" +
                              "&videoId=\(videoId)" +
                              "&videoURL=\(youtubeVideoId)" +
                              "&interaction=\(self.interaction)" +
                              "&action=" + action
            
            self.http.POST(self.interactionAPI!, paramToSend){ response in

                guard let session_data = response["success"] as? Int else{
                    
                    self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                        return
                }
                
                if session_data == 0 {
                    
                    //TODO: Handle having an invalid email address
                    self.alertFunctions.showAlert(self, "Error", msg: "Could not set interaction!")
                        return
                }
                
            }
            
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true)
        }
    }
    
    @IBAction func DislikeIconPressed(_ sender: UIButton) {
        
        self.interaction = 2
        let action:String = isInteractionBtnClicked(sender)
        
        if isSessionStored() {
            
            //Getting User info
            let userId =  preferences.integer(forKey: "userId")
            
            //Getting video info
            let videoId = self.video.getVideoId()
            let youtubeVideoId = self.video.getYouTubeId()
                      
            let paramToSend = "userId=\(userId)" +
                              "&videoId=\(videoId)" +
                              "&videoURL=\(youtubeVideoId)" +
                              "&interaction=\(self.interaction)" +
                              "&action=" + action
            
            self.http.POST(self.interactionAPI!, paramToSend){ response in
                
                guard let session_data = response["success"] as? Int else{
                              
                self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                    return
                }
                
                if session_data == 0 {
                    
                    //TODO: Handle having an invalid email address
                    self.alertFunctions.showAlert(self, "Error", msg: "Could not set interaction!")
                        return
                }
            }
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true, completion: nil)
        }
    }
    
    @IBAction func ShareIconPressed(_ sender: UIButton) {
        
        if isSessionStored() {
            
            let url = "http://www.youtube.com/embed/\(videoArray[0])"
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityController, animated: true, completion: nil)
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true, completion: nil)
            
            //TODO: Implement the share API 
        }
    }
    
    @IBAction func DownloadIconPressed(_ sender: UIButton) {
        
        if isSessionStored() {
            
            //TODO: Implement the Download API
            print("Supposed to do the Download API request")
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true, completion: nil)
        }
    }
    
    @IBAction func SaveIconPressed(_ sender: UIButton) {
        
        if isSessionStored() {
                   
            //TODO: Implement the Save API
            print("Supposed to do the Save API request")
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.login = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(self.login, animated: true, completion: nil)
        }
    }
    
    func getRandomVideos(_ numberOfVideos:Int) -> Array<String> {
        
        var videosArray:Array<String> = []
        
        let paramToSend = "numberOfVideos=\(numberOfVideos)"
        
        self.http.POST(self.randomVideosAPI!, paramToSend) { response in
    
            guard let session_data = response["success"] as? Int else{
                
                self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                return
            }
            
            if session_data == 0 {
                
                self.alertFunctions.showAlert(self ,"Error", msg: "Could not load videos!")
                    return
            }
            
            if let videos = response["info"] as? [[String : Any]] {
                
                for video in videos {
                    
                    for (key, value) in video {
            
                        if (key == "youtube_video_id") {
                            videosArray.append(value as! String)
                        }
                    }
                }
            }
        }
        sleep(1)
        return videosArray
    }
    
    private func isInteractionBtnClicked(_ button:UIButton) -> String {
        
        var action:String
        
        if (button.isSelected){
            
            button.isSelected = false
            action = "UNSET_INTERACTION"
        } else {
            
            button.isSelected = true
            action = "SET_INTERACTION"
        }
        return action
    }
}


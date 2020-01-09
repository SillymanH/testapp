//
//  ViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/22/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITableViewDelegate, UITableViewDataSource{

    //Outlets
    @IBOutlet weak var youTubeWebView: WKWebView!
    @IBOutlet weak var suggestedVideosTable: UITableView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    //APIs
    let interactionAPI = URL(string: "http://localhost:8888/test_db/Interactions.php/")
    let randomVideosAPI = URL(string: "http://localhost:8888/test_db/Videos.php/")
    let videosAPI = URL(string: "http://localhost:8888/test_db/Videos.php")
    
    //Global Instances
    let http:HTTPFunctions = HTTPFunctions();
    let person:Person = Person()
    var video:Video = Video()
    let alertFunctions: AlertFunctions = AlertFunctions()
    
    //Global Variables
    var videosArray = [String]()
        
//["Video 1",
//"Video 2",
//"Video 3",
//"Video 4",
//"Video 5",
//"Video 6"]
    
    let preferences = UserDefaults.standard
    
    // MARK: - Constants
    let appGroupName = "br.com.tntstudios.youtubeplayer"
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        videosArray = getRandomVideos(6)
        
        let youtubeVideoId = videosArray[0]
        
        let paramToSend = "youtubeVideoId=\(youtubeVideoId)"
        http.POST(self.videosAPI!, paramToSend) { response in
            
            guard let session_data = response["success"] as? Int else{
                
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
            
        }

        youTubeWebView.navigationDelegate = self
        youTubeWebView.configuration.allowsInlineMediaPlayback = false
        loadYoutubeIframe(youtubeVideoId: "kBmHYr_dUZc") // your Youtube video ID.
        
        //Getting suggested videos
        getSuggestedVideos()
    }
    
//     Programatically navigate to a new screen
//    @IBAction func Gotosubscribe(_ sender: Any) {
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "subscribe_view_controller") as! SubscribeViewController
//                self.present(newViewController, animated: true, completion: nil)
//    }
    
    // MARK: - UIWebViewDelegate
       
    func webView(_ webView: WKWebView, shouldStartLoadWith request: URLRequest, navigationType: WKNavigationType) -> Bool {
           if let url = request.url {
               
               // user is trying to get away of the application.
               if url.absoluteString.contains("https://www.youtube.com/watch") {
                   return false
               }
               
               if url.scheme == appGroupName {
                   
                   if let playerState = url.absoluteString.components(separatedBy: "=").last {
                       
                       // iframe API reference: https://developers.google.com/youtube/iframe_api_reference
                       
                       // -1 – unstarted
                       // 0 – ended
                       // 1 – playing
                       // 2 – paused
                       // 3 – buffering
                       // 5 – video cued
                       // 6 - ready
                       
                       switch playerState {
                       case "-1":
                           print("video State: unstarted")
                           break
                       case "0":
                           print("video State: ended")
                       case "1":
                           print("video State: playing")
                       case "2":
                           print("video State: paused")
                       case "3":
                           print("video State: buffering")
                       case "5":
                           print("video State: video cued")
                       case "6":
                           print("video State: ready")
                           break
                       default:
                           print("video State: LOL")
                       }
                       
                   }
                   
               }
           }
           return true
       }
    
    // MARK: - Helpers
       
       func loadYoutubeIframe(youtubeVideoId: String) {
           
           let html =
               "<html>" +
                   "<body style='margin: 0;'>" +
                   "<script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>" +
                   "<script type='text/javascript'> " +
                   "   function onYouTubeIframeAPIReady() {" +
                   "      ytplayer = new YT.Player('playerId',{events:{'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange}}) " +
                   "   } " +
                   "   function onPlayerReady(a) {" +
                   "       window.location = 'br.com.tntstudios.youtubeplayer://state=6'; " +
                   "   }" +
                   "   function onPlayerStateChange(d) {" +
                   "       window.location = 'br.com.tntstudios.youtubeplayer://state=' + d.data; " +
                   "   }" +
                   "</script>" +
                   "<div style='justify-content: center; align-items: center; display: flex; height: 100%;'>" +
                   "   <iframe id='playerId' type='text/html' width='100%' height='100%' src='https://www.youtube.com/embed/\(youtubeVideoId)?" +
                   "enablejsapi=1&rel=0&playsinline=0&autoplay=0&showinfo=0&modestbranding=1' frameborder='0'>" +
                   "</div>" +
                   "</body>" +
           "</html>"
           
           youTubeWebView.loadHTMLString(html, baseURL: nil)
       }
    
    func isSessionStored() -> Bool {
        
        if (preferences.object(forKey: "session") == nil){
            return false
        }
        return true
    }
    
    @IBAction func LikeIconPressed(_ sender: UIButton) {
        
        let interaction = 1
        let action:String = isInteractionBtnClicked(sender)
           
        if isSessionStored() {
            
            //TODO: Implement the Like API
            print("Supposed to do the Like API request")
            
            //Getting User info
            let userId = self.person.getUserId()
            
            //Getting video info
            let videoId = self.video.getVideoId()
            let youtubeVideoId = self.video.getYouTubeId()
            
            let paramToSend = "userId=\(userId)" +
                              "&videoId=\(videoId)" +
                              "&videoURL=\(youtubeVideoId)" +
                              "&interaction=\(interaction)" +
                              "&action=" + action
            
            http.POST(interactionAPI!, paramToSend){ response in

                guard let session_data = response["success"] as? Int else{
                    
                    self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                        return
                }
                
                if session_data == 0 {
                    
                    //TODO: Handle having an invalid email address
                    self.alertFunctions.showAlert(self, "Error", msg: "Could not set interaction!")
                        return
                }
                
                //TODO: Increment the interaction stats
                
            }
            
            
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func DislikeIconPressed(_ sender: UIButton) {
        
        if isSessionStored() {
            //TODO: Implement the Dislike API
            print("Supposed to do the Dislike API request")
            
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(newViewController, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func ShareIconPressed(_ sender: UIButton) {
        
        if isSessionStored() {
            
            //TODO: Implement the share API
            print("Supposed to do the Share API request")
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func DownloadIconPressed(_ sender: UIButton) {
        
        if isSessionStored() {
            
            //TODO: Implement the Download API
            print("Supposed to do the Download API request")
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func SaveIconPressed(_ sender: UIButton) {
        
        if isSessionStored() {
                   
            //TODO: Implement the Save API
            print("Supposed to do the Save API request")
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    
    func getSuggestedVideos(){
        
        suggestedVideosTable.dataSource = self
        suggestedVideosTable.delegate = self
        suggestedVideosTable.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SuggestedVideosCell = tableView.dequeueReusableCell(withIdentifier: "suggested_videos_cell") as! SuggestedVideosCell
        cell.suggestedVideosLabel.text = videosArray[indexPath.row]
            return cell
    }
    
    func getRandomVideos(_ numberOfVideos:Int) -> Array<String> {
        
        var videosArray = [String]()
        
        let paramToSend = "numberOfVideos=\(numberOfVideos)"
        http.POST(self.randomVideosAPI!, paramToSend) { response in
            
            guard let session_data = response["success"] as? Int else{
                
                self.alertFunctions.showAlert(self, "Error", msg: "Something went wrong!")
                return
            }
            
            if session_data == 0 {
                
                self.alertFunctions.showAlert(self ,"Error", msg: "Could not load videos!")
                    return
            }
            
            if let videos = response["videos"] as? NSDictionary  {
                
                for (key, value) in videos {
                    
                    if (key as! String == "youtubeVideoId") {
                        
                        videosArray.append(value as! String)
                    }
                }
            }
        }
        return videosArray
    }
    
    private func isInteractionBtnClicked(_ button:UIButton) -> String {
        
        var action:String
        
        if (button.isSelected){
            
            likeBtn.isSelected = false
            action = "SET_INTERACTION"
        } else {
            
            likeBtn.isSelected = true
            action = "UNSET_INTERACTION"
        }
        return action
    }
}


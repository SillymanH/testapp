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

    @IBOutlet weak var youTubeWebView: WKWebView!
    @IBOutlet weak var suggestedVideosTable: UITableView!
    let preferences = UserDefaults.standard
   
   
    
    
    // MARK: - Constants
    let appGroupName = "br.com.tntstudios.youtubeplayer"
    
    var videos : [String] =  ["Video 1",
                              "Video 2",
                              "Video 3",
                              "Video 4",
                              "Video 5",
                              "Video 6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
       
//    @objc func onEnterFullScreen() {
//           print("Enter fullscreen")
//    }
//
//    @objc func onCloseFullScreen() {
//           print("Exit fullscreen")
//    }
    
    @IBAction func LikeIconPressed(_ sender: UIButton) {
           
           if (preferences.object(forKey: "session") == nil){
               let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
               let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
               self.present(newViewController, animated: true, completion: nil)
           }
           //TODO: Implement the Like Request
           print("Supposed to do the Like API request")
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
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SuggestedVideosCell = tableView.dequeueReusableCell(withIdentifier: "suggested_videos_cell") as! SuggestedVideosCell
        cell.suggestedVideosLabel.text = videos[indexPath.row]
            return cell
    }

}


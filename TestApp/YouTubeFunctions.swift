//
//  YouTubeFunctions.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/9/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import Foundation
import WebKit

class YoutubeFunctions {
    
    // MARK: - Constants
      let appGroupName = "br.com.tntstudios.youtubeplayer"
    
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
    
    func loadYoutubeIframe(_ youtubeVideoId: String,_ youTubeWebView:WKWebView ) {
        
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
    
    func prepYoutubeView(_ youtubeVideoId:String,_ webView: WKWebView, classInstance:AnyObject ) {
        
        webView.navigationDelegate = self as? WKNavigationDelegate
        webView.configuration.allowsInlineMediaPlayback = false
        loadYoutubeIframe(youtubeVideoId, webView) //Loading video on the video view using youtube id
    }
    
    public func statCheck(_ statNumber:Int) -> String {
        
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
}

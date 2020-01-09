//
//  Video.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/8/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import Foundation

class Video {
    
    // Properties
    private var videoId:Int = 0
    private var channelId:Int = 0
    private var videoLikes:Int = 0
    private var videoDislikes:Int = 0
    private var videoShares:Int = 0
    private var videoDownloads:Int = 0
    private var videoSaves:Int = 0
    private var videoTitle:String = ""
    private var youtubeVideoId:String = ""
    
    init() {}
    
    // Setters
    public func setVideoId(_ videoId:Int) {

        self.videoId = videoId
       }

    public func setChannelId(_ channelId:Int) {

        self.channelId = channelId
       }

    public func setVideoLikes(_ videoLikes:Int) {

        self.videoLikes = videoLikes
       }

       public func setVideoDislikes(_ videoDislikes:Int) {

        self.videoDislikes = videoDislikes
       }

       public func setVideoShares(_ videoShares:Int) {

        self.videoShares = videoShares
       }

       public func setVideoDownloads(_ videoDownloads:Int) {

        self.videoDownloads = videoDownloads
       }

       public func setVideoSaves(_ videoSaves:Int) {

        self.videoSaves = videoSaves
       }

    public func setVideoTitle(_ videoTitle:String) {

        self.videoTitle = videoTitle
       }

       public func setYoutubeId(_ youtubeVideoId:String) {

        self.youtubeVideoId = youtubeVideoId
       }

       //Getters
       public func getVideoId() -> Int{

        return self.videoId
       }

       public func getChannelId() -> Int {

        return self.channelId
       }

       public func getVideoLikes() -> Int {

        return self.videoLikes
       }

       public func getVideoDislikes() -> Int {

           return self.videoDislikes
       }

       public func getVideoShares() -> Int {

           return self.videoShares
       }

       public func getVideoDownloads() -> Int {

           return self.videoDownloads
       }

       public func getVideoSaves() -> Int {

          return self.videoSaves
       }

       public func getVideoTitle() -> String {

           return self.videoTitle
       }

       public func getYouTubeId() -> String {

          return self.youtubeVideoId
       }
    
}

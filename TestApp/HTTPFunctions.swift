//
//  HTTPFunctions.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/27/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import Foundation
import Photos
import UIKit

class HTTPFunctions {
    
    func DoRequestReturnJSON(_ string_url:String = "",_ params:String = "",_ httpMethod:String = "", CustomRequest:NSMutableURLRequest?, completionBlock: @escaping (Any) -> Void) {
        
        let session = URLSession.shared

        let request:NSMutableURLRequest
        
        if (CustomRequest != nil) {
            
            request = CustomRequest!
        } else {
            
            var url = string_url
            
            if httpMethod == "GET" {
                
                url = string_url + "?\(params)"
            }
            
            let requestURL = URL(string: url)
            request = NSMutableURLRequest(url: requestURL!)
            request.httpMethod = httpMethod
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            if httpMethod == "POST" {
                
               request.httpBody = params.data(using: String.Encoding.utf8)
            }
        }
    
        let group = DispatchGroup()
        group.enter() // Entering the code block which will get executed

        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
        (data, response, error) in
            
//        print(response as Any)

        if error != nil {
            print(error as Any)
            return
        }


        let json:Any?

        do
        {
            json = try JSONSerialization.jsonObject(with: data!, options: [])
            print(json as Any)
        }
        catch
        {
            print(error)
            return
        }
            completionBlock(json as Any)
            group.leave() // Leaving the code block
        })
        task.resume()
        group.wait() // Thread waits for the code block to finish
    }
    
    func DownloadVideo(_ url_string:String, completionBlock: @escaping (Bool) -> Void) {

        let sampleURL = "http://localhost:8888/test_db/videos/demo.mov" // Demo video just to test the function

        DispatchQueue.global(qos: .background).async {
          
            if let url = URL(string: sampleURL), let urlData = NSData(contentsOf: url) {

              let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
              let filePath="\(galleryPath)/demo2.mov"

            DispatchQueue.main.async {

                urlData.write(toFile: filePath, atomically: true)
                PHPhotoLibrary.shared().performChanges({
                    
                    //TODO: Add spinner

                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:
                    URL(fileURLWithPath: filePath))}) { success, error in

                        if success {
                            print("Succesfully Saved")
                            completionBlock(true)
                    } else {
                            print(error?.localizedDescription as Any)
                            completionBlock(true)
                            
                        }
                    }
                 }
              }
           }
        }
    
    func DoRequestReturnCompleteResponse(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
       
       let session = URLSession.shared
       let request = NSMutableURLRequest(url: url)
       request.httpMethod = "GET"
       
//       let group = DispatchGroup()
//       group.enter() // Entering the code block which will get executed
     
       let task = session.dataTask(with: request as URLRequest) {
           data, response, error in
        
        if error != nil {
            print(error as Any)
            return
        }
           completion(data, response, error)
//           group.leave() // Leaving the code block
       }
       task.resume()
//       group.wait() // Thread waits for the code block to finish
       }
    
    func DownloadImage(from url: String) -> Data {
    
        var imageData:Data = Data()
        
        let group = DispatchGroup()
        group.enter() // Entering the code block which will get executed
        
        let photoURL = URL(string: url)
        
        self.DoRequestReturnCompleteResponse(from: photoURL!) { data, response, error in
        
            guard let data = data, error == nil else {
                
                print(error as Any)
                return
            }
                
            imageData = data
            
            group.leave() // Leaving the code block
        }
        group.wait() // Thread waits for the code block to finish
        return imageData
    }
    
    func UploadImage(_ uploadURL:NSURL, _ param:[String:String], _ httpMethod:String, Myimage:UIImage) -> [String : String] {

        let request = NSMutableURLRequest(url:uploadURL as URL)
        request.httpMethod = httpMethod
        
        let boundary =  GenerateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var result:[String : String] = [:]
        let imageData = Myimage.jpegData(compressionQuality: 1)
        
        if(imageData == nil)  {
            
            result = ["Error":"Something went wrong!"]
                return result
        }
        
        request.httpBody = CreateBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data

        DoRequestReturnJSON(CustomRequest: request){ json in
            
            guard let response = json as? NSDictionary else {
                
                result = ["Error":"Something went wrong!"]
                    return
            }
            
            guard ((response["Status"] as? String) == "OK") else {
                
                result = ["Error":"Sorry, there was an error uploading your image."]
                    return
            }
            result = ["Success":response["Message"] as! String]
        }
        return result
    }

    func CreateBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData()

        if parameters != nil {
                for (key, value) in parameters! {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.appendString("\(value)\r\n")
                }
            }
        
                    let filename = "user-profile.jpg"
                    let mimetype = "image/jpg"
                    
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
                    body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                    body.append(imageDataKey as Data)
                    body.appendString("\r\n")
                    body.appendString("--\(boundary)--\r\n")
                    
                    return body
    }
    
    func GenerateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension NSMutableData {
   
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

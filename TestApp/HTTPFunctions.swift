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
    
    func doRequest(_ string_url:String,_ params:String,_ httpMethod:String, completionBlock: @escaping (NSDictionary) -> Void) {
        
        var url = string_url
        
        if httpMethod == "GET" {
            
            url = string_url + "?\(params)"
        }
        
        let requestURL = URL(string: url)
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: requestURL!)
        request.httpMethod = httpMethod
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        if httpMethod == "POST" {
            
           request.httpBody = params.data(using: String.Encoding.utf8)
        }

        let group = DispatchGroup()
        group.enter() // Entering the code block which will get executed

        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
        (data, response, error) in

        guard let _:Data = data else
        {
            return
        }

        let json:Any?

        do
        {
            json = try JSONSerialization.jsonObject(with: data!, options: [])
        }
        catch
        {
            return
        }
            guard let server_response = json as? NSDictionary else {
                return
            }

            print(server_response)
            completionBlock(server_response)
            group.leave() // Leaving the code block
        })
        task.resume()
        group.wait() // Thread waits for the code block to finish
    }
    
   func imageRequest(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    
    let session = URLSession.shared
    let request = NSMutableURLRequest(url: url)
    request.httpMethod = "GET"
  
    let task = session.dataTask(with: request as URLRequest) {
        data, response, error in
    
        return completion(data, response, error)
    }
    task.resume()
    }
    
    func Download(_ url_string:String, completionBlock: @escaping (Bool) -> Void) {

        let sampleURL = "http://localhost:8888/test_db/videos/demo.mov" // Demo video just to test the function

        DispatchQueue.global(qos: .background).async {
          
            if let url = URL(string: sampleURL), let urlData = NSData(contentsOf: url) {

              let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
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
    
    func downloadImage(from url: URL) -> Data {
        print(url)
        
        var imageData:Data = Data()
        
        let group = DispatchGroup()
        group.enter() // Entering the code block which will get executed
        
        self.imageRequest(from: url) { data, response, error in
        
            guard let data = data, error == nil else { return }
            
            print(response?.suggestedFilename ?? url.lastPathComponent)
                
            imageData = data
            
            group.leave() // Leaving the code block
        }
        group.wait() // Thread waits for the code block to finish
        return imageData
    }
    
    func UploadImage(Myimage:UIImage) {

        let myUrl = NSURL(string: "http://localhost:8888/test_db/uploads/Upload.php");

        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";

        let param = [
            "firstName"  : "Sergey",
            "lastName"   : "Kargopolov",
            "userId"     : "9"
        ]

        let boundary =  generateBoundaryString()

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")


        let imageData = Myimage.jpegData(compressionQuality: 1)

        if(imageData==nil)  { return; }

        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data

        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in

            if error != nil {
                print(error as Any)
                return
            }

            // You can print out response object
            print(response as Any)

            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary

                print(json as Any)

            }catch
            {
                print(error)
            }

        }

        task.resume()
    }

    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();

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
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension NSMutableData {
   
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

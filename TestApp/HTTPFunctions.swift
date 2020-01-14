//
//  HTTPFunctions.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/27/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import Foundation

class HTTPFunctions {
    
    func POST(_ requestURL:URL,_ params:String, completionBlock: @escaping (NSDictionary) -> Void) {
        
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = params.data(using: String.Encoding.utf8)
        
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
        })
        task.resume()
    }
}

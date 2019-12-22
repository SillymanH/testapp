//
//  SubscribeViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/22/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import UIKit

class SubscribeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var subscribeOptions: UITableView!
    var videos : [String] =  ["Video 1",
                              "Video 2",
                              "Video 3",
                              "Video 4",
                              "Video 5",
                              "Video 6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Subscribe"
        getSubscribeOptions()
    }
    
    func getSubscribeOptions(){
           
           subscribeOptions.dataSource = self
           subscribeOptions.delegate = self
           subscribeOptions.reloadData()
       }

       func numberOfSections(in tableView: UITableView) -> Int {
             return 1
         }

         func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             return videos.count
         }

         func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

               //let videoTitle = videos[indexPath.row]
                 let cell : PrototypeViewCell = tableView.dequeueReusableCell(withIdentifier: "prototype_cell") as! PrototypeViewCell
           cell.prototypeLable.text = videos[indexPath.row]
                 return cell
         }

}

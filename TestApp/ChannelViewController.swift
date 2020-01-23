//
//  ChannelViewController.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/22/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import UIKit

class ChannelViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Outlets
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var subscriberNumber: UILabel!
    
    //Global Variables
    var imagePicker: ImagePicker!
    var isCoverUpload:Bool = false // This flag is to determine if user wants to upload a cover or a profile
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func CoverPhotoUploadBtnPressed(_ sender: UIButton) {
        
        self.isCoverUpload = true
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func ProfileImageUploadBtnPressed(_ sender: UIButton) {
        
        self.isCoverUpload = false
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func SubscribePressed(_ sender: UIButton) {
        
    }
}

extension ChannelViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        
        if self.isCoverUpload {
            
            self.coverPhoto.image = image
        }else {
            
             self.profileImage.image = image
        }
        
    }
}

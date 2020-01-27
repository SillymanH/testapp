//
//  ImagePicker.swift
//  TestApp
//
//  Created by Sleiman Hasan on 1/23/20.
//  Copyright © 2020 Sleiman Hasan. All rights reserved.
//

import UIKit

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?) -> String
}

open class ImagePicker: NSObject {

    //Global Variables
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    private var channel:Channel?
    private var photoType:String?
   

    init(presentationController: UIViewController, delegate: ImagePickerDelegate, channel: Channel) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
        self.channel = channel
        
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        photoType = self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
        
        DispatchQueue.global().async {
            
            let uploadURL = NSURL(string: "http://localhost:8888/test_db/Upload.php")
            let httpMethod = "POST"
            let param:[String:String] = ["photoType": self.photoType!, "channelId": "\(self.channel!.getChannelId())"]
            let http:HTTPFunctions = HTTPFunctions()
            let response = http.UploadImage(uploadURL!, param, httpMethod, Myimage: image)
            
            var status:String = "Success"
            if ((response["Error"]) != nil) {
                status = "Error"
            }
            let alert:AlertFunctions = AlertFunctions()
            alert.showAlert(self.presentationController!, status, msg: response[status]!)
        }
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}

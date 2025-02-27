//
//  SuggestedVideosCell.swift
//  TestApp
//
//  Created by Sleiman Hasan on 12/22/19.
//  Copyright © 2019 Sleiman Hasan. All rights reserved.
//

import UIKit
import WebKit

class SuggestedVideosCell: UITableViewCell {

    @IBOutlet weak var suggestedVideosLabel: UILabel!
    @IBOutlet weak var suggestedVideoWebView: WKWebView!
    @IBOutlet weak var allVideosWebView: WKWebView! // This is for the channelInfo view controller
    @IBOutlet weak var allVideosLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

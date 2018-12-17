//
//  FirstRouteCollectionViewCell.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 24..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit

class FirstRouteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var upImageView: UIImageView!
    @IBOutlet weak var busStopLabel: UILabel!
    
    var busStop: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.upImageView.layer.cornerRadius = self.upImageView.frame.height / 2
        
        self.busStopLabel.translatesAutoresizingMaskIntoConstraints = false
        self.busStopLabel.leftAnchor.constraint(equalTo: self.upImageView.rightAnchor, constant: 10).isActive = true
        self.busStopLabel.centerYAnchor.constraint(equalTo: self.upImageView.centerYAnchor).isActive = true
        self.busStopLabel.sizeToFit()
//        self.busStopLabel.text = busStop
        
    }

}

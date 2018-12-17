//
//  RouteCollectionViewCell.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 22..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit

class RouteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var downImageView: UIImageView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var leftBusStopLabel: UILabel!
    @IBOutlet weak var rightBusStopLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.leftBusStopLabel.text = nil
        self.rightBusStopLabel.text = nil
        
        self.middleView.translatesAutoresizingMaskIntoConstraints = false
        
        self.middleView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.middleView.bottomAnchor.constraint(equalTo: self.downImageView.topAnchor, constant: 0).isActive = true
        self.middleView.centerXAnchor.constraint(equalTo: self.downImageView.centerXAnchor).isActive = true
        self.middleView.widthAnchor.constraint(equalToConstant: 2).isActive = true
        
        self.middleView.layer.borderWidth = 1
        self.middleView.layer.borderColor = UIColor(red: 25/255, green: 118/255, blue: 210/255, alpha: 1).cgColor
        
        self.downImageView.layer.cornerRadius = self.downImageView.frame.height / 2
        
        self.turnLabel.translatesAutoresizingMaskIntoConstraints = false
        self.turnLabel.centerYAnchor.constraint(equalTo: self.middleView.centerYAnchor).isActive = true
        self.turnLabel.leftAnchor.constraint(equalTo: self.middleView.rightAnchor, constant: 20).isActive = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.leftBusStopLabel.text = nil
        self.rightBusStopLabel.text = nil
        self.turnLabel.isHidden = true
    }

}

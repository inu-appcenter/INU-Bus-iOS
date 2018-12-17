//
//  MapViewController.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 29..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        mapImageView.translatesAutoresizingMaskIntoConstraints = false
        let constant: Double = Double(Double(UIScreen.main.bounds.height / 667) * 185.5)
        mapImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(constant)).isActive = true
        mapImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        mapImageView.widthAnchor.constraint(equalToConstant: 321).isActive = true
        mapImageView.heightAnchor.constraint(equalToConstant: 321).isActive = true
        mapImageView.clipsToBounds = true
        mapImageView.layer.cornerRadius = 25
        
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = mapView.layer.bounds.size.width / 2
        mapView.clipsToBounds = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.widthAnchor.constraint(equalToConstant: 86).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: 86).isActive = true
        mapView.topAnchor.constraint(equalTo: mapImageView.topAnchor, constant: -(mapView.frame.height / 2)).isActive = true
        mapView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        self.mapLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mapLabel.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor).isActive = true
        self.mapLabel.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor).isActive = true
     
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapView(_:)))
        
        self.view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tapView(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

}

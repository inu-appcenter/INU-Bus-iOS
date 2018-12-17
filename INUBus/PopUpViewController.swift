//
//  PopUpViewController.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 16..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var timer = Timer()
    
    let serverURL = "http://inucafeteriaaws.us.to:3829/"
    
    var inquiryTitle: String = ""
    var inquiryContact: String = ""
    var inquiryMessage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupView()
        self.startTimer()
        self.jsonPost()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension PopUpViewController {
    func setupView() {
        //main view autolayout
        self.mainView.translatesAutoresizingMaskIntoConstraints = false
        
        self.mainView.widthAnchor.constraint(equalToConstant: 308).isActive = true
        self.mainView.heightAnchor.constraint(equalToConstant: 136).isActive = true
        self.mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        //topAnchor by devices
        let constant: Double = Double(Double(UIScreen.main.bounds.height / 667)*241)
        self.mainView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(constant)).isActive = true
        
        
        self.mainView.layer.cornerRadius = 25
        
        //label autolayout
        self.thanksLabel.translatesAutoresizingMaskIntoConstraints = false
        self.thanksLabel.centerXAnchor.constraint(equalTo: self.mainView.centerXAnchor).isActive = true
        self.thanksLabel.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor).isActive = true
        
        //when parent view's alpha property is changed in storyboard, all subview properties are changed.
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        
        //imageView initializing to circle
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor(white: 215/255, alpha: 1).cgColor
        self.imageView.layer.masksToBounds = false
        self.imageView.layer.cornerRadius = self.imageView.frame.height / 2
        self.imageView.backgroundColor = .white
        self.imageView.clipsToBounds = true
        
        //imageView autolayout
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.topAnchor.constraint(equalTo: self.mainView.topAnchor, constant: -(self.imageView.frame.height / 2)).isActive = true
        self.imageView.centerXAnchor.constraint(equalTo: self.mainView.centerXAnchor).isActive = true
        self.imageView.widthAnchor.constraint(equalToConstant: 76).isActive = true
        self.imageView.heightAnchor.constraint(equalToConstant: 76).isActive = true
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.dismissViewController), userInfo: nil, repeats: true)
    }
    
    //2 viewControllers dismiss
    @objc func dismissViewController() {
        let presentingViewController = self.presentingViewController
        self.dismiss(animated: true, completion: {
            presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func jsonPost() {
        
        let inquiry: Inquiry = Inquiry(service: "inu.appcenter.INUBus", title: self.inquiryTitle, contact: self.inquiryContact, message: self.inquiryMessage, device: "\(UIDevice.modelName) \(UIDevice.current.systemVersion)")
        
        guard let url = URL(string: "\(self.serverURL)errormsg") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(inquiry)
            request.httpBody = data
            print("encoding success!")
            print(data)
        } catch {
            print(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("post error")
            }
            
            }.resume()
        
    }
    
}


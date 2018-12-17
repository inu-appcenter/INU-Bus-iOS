//
//  InquiryViewController.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 10..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit

class InquiryViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViewController()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchUpCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func titleTextFieldEditingChanged(_ sender: Any) {
        self.contentsCheck()
    }
    
    @IBAction func phoneNumberTextFieldEditingChanged(_ sender: Any) {
        self.contentsCheck()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PopUpViewController {
            viewController.inquiryTitle = self.titleTextField.text ?? ""
            viewController.inquiryContact = self.phoneNumberTextField.text ?? ""
            viewController.inquiryMessage = self.contentsTextView.text ?? ""
        }
    }

}

extension InquiryViewController {
    private func setupViewController() {
        self.titleTextField.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        self.phoneNumberTextField.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        self.contentsTextView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        self.titleTextField.layer.borderWidth = 1
        self.phoneNumberTextField.layer.borderWidth = 1
        self.contentsTextView.layer.borderWidth = 1
        self.contentsTextView.layer.cornerRadius = 6
        
        
        
        let viewControllerTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapViewController(_:)))
        self.view.addGestureRecognizer(viewControllerTapGesture)
        
        self.contentsTextView.delegate = self
    }
    
    @objc func tapViewController(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.contentsCheck()
    }
    
    func contentsCheck() {
        if self.titleTextField.text != "" && self.phoneNumberTextField.text != "" && self.contentsTextView.text != "" {
            self.sendButton.isEnabled = true
        } else {
            self.sendButton.isEnabled = false
        }
    }
}

extension InquiryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.contentsCheck()
    }
}

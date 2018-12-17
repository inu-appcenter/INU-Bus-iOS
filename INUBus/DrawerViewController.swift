//
//  DrawerViewController.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 7. 21..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchUpBackButton(_ sender: Any) {
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
        }
    }

}

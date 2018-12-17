//
//  Singleton.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 11. 7..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import Foundation

class Singleton {
    static let shared = Singleton()
    
    // MARK: Download URL
    let url = "http://inucafeteria1.us.to:1337/"
    
    // MARK: Engineering bus stop data
    let destinationFromEngineering = ["인천대입구역", "지식정보단지역", "해양경찰청", "구월동", "신연수"]
    let busFromEngineering = [["8  780  780-1  780-2", "908  909", "92"],
                              ["6  6-1  6-3", "909", "92"],
                              ["8  780-1  780-2  6-1"],
                              ["780-2", "908"],
                              ["708-1  780-2", "908  909", "3002"],]
}

//
//  Inquiry.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 17..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import Foundation

struct Inquiry: Codable {
    let service: String
    let title: String
    let contact: String
    let message: String
    let device: String
    
    enum CodingKeys: String, CodingKey {
        case service, title, contact, device 
        case message = "msg"
    }
}

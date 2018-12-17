//
//  BusStop.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 17..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import Foundation

struct Bus: Codable {
    let no: String
    let arrival: Int
    let start: Int
    let end: Int
    let interval: Int
    let type: String
}

struct BusStop: Codable {
    let name: String
    let data: [Bus]
}

struct Station: Codable {
    let id: String
    let data: [Bus]
}

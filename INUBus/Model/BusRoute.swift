//
//  BusRoute.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 24..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import Foundation

struct BusRoute: Codable {
    let no: String
    let routeId: String
    let nodeList: [String]
    let turnNode: String
    let start: Int
    let end: Int
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case no, start, end, type
        case routeId = "routeid"
        case nodeList = "nodelist"
        case turnNode = "turnnode"
    }
}

//
//  CellUpdateDelegate.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 29..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import Foundation

protocol CellUpdateDelegate {
    func updateTableView()
}

protocol SearchResultDelegate {
    func fetchBusName(array: [String], searchWord: String, searched: Bool)
}



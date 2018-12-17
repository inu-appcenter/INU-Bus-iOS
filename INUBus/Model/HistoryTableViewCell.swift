//
//  HistoryTableViewCell.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 31..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var busStopLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var dateForSort: Date?
    
    var delegate: CellUpdateDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.historyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.historyLabel.centerYAnchor.constraint(equalTo: self.busStopLabel.centerYAnchor).isActive = true
        let constant = (Double(UIScreen.main.bounds.width) / 375) * 194.5
        self.historyLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: CGFloat(constant)).isActive = true
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override func prepareForReuse() {
//        self.busStopLabel = nil
//        self.historyLabel = nil
//        self.deleteButton = nil
//    }
//
    @IBAction func touchUpDeleteButton(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchHistory")

        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [SearchHistory]

        
        
        for object in resultData {
            if object.dateForSort == self.dateForSort {
                managedContext.delete(object)
                break
            }
        }
        

        do {
            try managedContext.save()
            print("delete")
            self.delegate?.updateTableView()
            
        } catch let err as NSError {
            print("Failed save after delete", err)
        }
        
        
    }
}

//
//  TimeTableViewCell.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 7. 22..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit
import CoreData

class TimeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var busNumber: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var intervalTime: UILabel!
    
    var busStopType = "FrontGate"
    var delegate: CellUpdateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if UIScreen.main.bounds.width < 350 {
            self.busNumber.font = self.busNumber.font.withSize(24)
            self.arrivalTime.font = self.arrivalTime.font.withSize(12)
            self.intervalTime.font = self.intervalTime.font.withSize(12)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.busNumber.textColor = UIColor(red: 47/255, green: 96/255, blue: 206/255, alpha: 1)
        self.favoritesButton.isHidden = false
        self.favoritesButton.setImage(UIImage(named: "icFavor"), for: .normal)
    }
    
    @IBAction func touchUpFavoritesButton(_ sender: Any) {
        if favoritesButton.imageView?.image == UIImage(named: "icFavor") {
            favoritesButton.setImage(UIImage(named: "icFavorPressed"), for: .normal)
            self.saveFavorData()
            self.delegate?.updateTableView()
            
        } else {
            favoritesButton.setImage(UIImage(named: "icFavor"), for: .normal)
            self.deleteFavorData()
            self.delegate?.updateTableView()
        }
    }
    
    func saveFavorData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: self.busStopType, in: managedContext)
        let item = NSManagedObject(entity: entity!, insertInto: managedContext)
        item.setValue(self.busNumber.text, forKey: "busName")
        
        do {
            try managedContext.save()
        } catch let err as NSError {
            print("Failed to save an item", err)
        }
        
    }
    
    func deleteFavorData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FrontGate")
        
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [FrontGate]
        
        for object in resultData {
            if object.busName == self.busNumber.text {
                managedContext.delete(object)
            }
        }
        
        do {
            try managedContext.save()
            print("delete")
        } catch let err as NSError {
            print("Failed save after delete", err)
        }
        
    }
    
}

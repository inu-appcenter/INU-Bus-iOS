//
//  SearchViewController.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 30..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, CellUpdateDelegate {
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var seachTextField: UITextField!
    
    let jsonUrlString: String = "http://inucafeteria1.us.to:1337/getNodes"
    var foundBusName: [String] = []
    var searchHistory: [SearchHistory] = []
    
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
    
    var delegate: SearchResultDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializing()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateTableView() {
        self.fetchSearchHistory()
        self.historyTableView.reloadData()
    }
    
    func jsonParsing(word: String) {
        guard let url = URL(string: self.jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else { return }
            
            do {
                let busRoute = try JSONDecoder().decode([BusRoute].self, from: data)
                
                let group = DispatchGroup()

                group.enter()
                DispatchQueue.main.async {
                    self.foundBusName = []
                    for object in busRoute {
                        for value in object.nodeList {
                            if value.contains(word) {
                                self.foundBusName.append(object.no)
                                break
                            }
                        }
                    }
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    self.delegate?.fetchBusName(array: self.foundBusName, searchWord: word, searched: true)
                }
                
                print("search success")
            } catch let jsonErr {
                print(jsonErr)
            }
            }.resume()
    }
    
    func fetchSearchHistory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
        let sort = NSSortDescriptor(key: #keyPath(SearchHistory.dateForSort), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            self.searchHistory = try managedContext.fetch(fetchRequest)
            print("data fetch success")
        } catch let err as NSError {
            print("Failed to fetch items", err)
        }
    }
    
    func saveSearchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SearchHistory", in: managedContext)
        let item = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        
        item.setValue(self.seachTextField.text, forKey: "busStopName")

        let date: Date = Date()
        item.setValue(date, forKey: "dateForSort")
        item.setValue(self.dateFormatter.string(from: date), forKey: "date")
        
        do {
            try managedContext.save()
        } catch let err as NSError {
            print("Failed to save an item", err)
        }
    }
    
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        self.delegate?.fetchBusName(array: [], searchWord: "", searched: false)
        self.navigationController?.popViewController(animated: false)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let word = self.seachTextField.text!
        jsonParsing(word: word)
        self.saveSearchData()
        self.navigationController?.popViewController(animated: false)
        
        return true
    }
}


extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func initializing() {
        self.historyTableView.dataSource = self
        self.historyTableView.delegate = self
        self.historyTableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        
        self.seachTextField.delegate = self
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.seachTextField.becomeFirstResponder()
        
        self.fetchSearchHistory()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.historyTableView.deselectRow(at: indexPath, animated: false)
        let word = self.searchHistory[indexPath.row].busStopName
        jsonParsing(word: word!)
        self.navigationController?.popViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.historyTableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as! HistoryTableViewCell
        
        
        cell.busStopLabel.text = self.searchHistory[indexPath.row].busStopName
        cell.historyLabel.text = self.searchHistory[indexPath.row].date
        
        
        cell.delegate = self
        
        cell.dateForSort = self.searchHistory[indexPath.row].dateForSort
        
        return cell
    }
    
    
}


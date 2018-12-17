//
//  EngineeringViewController.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 7. 22..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit
import CoreData
import BetterSegmentedControl
import KYDrawerController
import Floaty

class EngineeringViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellUpdateDelegate, SearchResultDelegate {

    // MARK:- IBOutlet
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var destinationTableView: UITableView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var historyTableView: UITableView!
    
    // MARK: Properties
    let busType = ["즐겨찾기", "간선버스", "간선급행", "광역버스"]
    let destinations = ["인천대입구역", "지식정보단지역", "해양경찰청", "구월동", "신연수"]
    let destinationBus = [["8  780  780-1  780-2", "908  909", "92"],
                          ["6  6-1  6-3", "909", "92"],
                          ["8  780-1  780-2  6-1"],
                          ["780-2", "908"],
                          ["708-1  780-2", "908  909", "3002"],]
    
    let jsonUrlString: String = "http://inucafeteria1.us.to:1337/arrivalinfoFrom"
    let busStopName: String = "frontgate"
    let busStopType: String = "FrontGate"
    var buses: [Bus] = []
    var sortedBuses: [[Bus]] = [[], [], [], []]
    var foundBusName: [String] = []
    var isSearched: Bool = false
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    var oneSecTimer: Timer!
    var thirtySecTimer: Timer!
    var favorBus: [NSManagedObject] = []
    
    var floaty = Floaty()
    
    // MARK:- Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.jsonParsing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initializing()
        self.fetchFavorBus()
        print(self.foundBusName)
        self.startTimer()
        
//        setupFloaty()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.endTimer()
    }
    
    func fetchBusName(array: [String], searchWord: String, searched: Bool) {
        self.foundBusName = array
        self.isSearched = searched
        self.searchTextField.text = searchWord
        self.jsonParsing()
    }

    
    func fetchFavorBus() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.busStopType)
        
        
        do {
            self.favorBus = try managedContext.fetch(fetchRequest)
            print("data fetch success")
        } catch let err as NSError {
            print("Failed to fetch items", err)
        }
        
    }
    
    
    @objc func jsonParsing() {
        guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else { return }
            
            do {
                let busStop = try JSONDecoder().decode([BusStop].self, from: data)
                for value in busStop {
                    if value.name == self.busStopName {
                        self.buses = value.data
                        self.sortBuses()
                        break
                    }
                }
                print("bus arrival time download success")
                
            } catch let jsonErr {
                print(jsonErr)
            }
            }.resume()
        
    }
    
    func sortBuses() {
        self.sortedBuses = [[], [], [], []]
        
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.async {
            self.fetchFavorBus()
            
            if self.isSearched {
                for temp in self.foundBusName {
                    for value in self.buses {
                        if value.no != temp {
                            continue
                        }
                        
                        for object in self.favorBus as! [FrontGate] {
                            if value.no == object.busName {
                                self.sortedBuses[0].append(value)
                                break
                            }
                        }
                        switch value.type {
                        case "간선":
                            self.sortedBuses[1].append(value)
                        case "간선급행":
                            self.sortedBuses[2].append(value)
                        case "광역":
                            self.sortedBuses[3].append(value)
                        default:
                            print("unexpected data")
                        }
                    }
                }
                
            } else {
                for value in self.buses {
                    for object in self.favorBus as! [FrontGate] {
                        if value.no == object.busName {
                            self.sortedBuses[0].append(value)
                            break
                        }
                    }
                    switch value.type {
                    case "간선":
                        self.sortedBuses[1].append(value)
                    case "간선급행":
                        self.sortedBuses[2].append(value)
                    case "광역":
                        self.sortedBuses[3].append(value)
                    default:
                        print("unexpected data")
                    }
                }
            }
            
            group.leave()
        }

        group.notify(queue: .main) {
            self.timeTableView.reloadData()
        }
    }
    
    func getArrivalTime(arrival: Int, start: Int, end: Int, interval: Int) -> Int {
        let date = Date()
        let currentHour = Calendar.current.component(.hour, from: date)
        let currentMinute = Calendar.current.component(.minute, from: date)
        let currentTime = currentHour * 100 + currentMinute
        
        //막차가 0시를 넘어가는 경우 첫 if문
        if end < start {
            if end < currentTime && currentTime < start {
                //운행종료
                return -1
            }
        } else {
            if start > currentTime || currentTime > end {
                //운행 종료
                return -1
            }
        }
        
        var second = Int((Double(arrival - Date().millisecondsSince1970) / 1000).rounded())
        
        while(true) {
            if second > 0 {
                return second
            } else {
                second = second + (interval * 60)
            }
        }
        
    }
    
    @IBAction func touchUpInforButton(_ sender: Any) {
        if let drawerController = tabBarController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    @IBAction func touchUpRetryButton(_ sender: UIButton) {
        self.jsonParsing()
    }
    
    @objc func controlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            self.timeTableView.isHidden = false
            self.warningLabel.isHidden = false
            self.labelBackgroundView.isHidden = false
            self.leftLabel.isHidden = false
            self.rightLabel.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
            self.destinationTableView.isHidden = true
            self.retryButton.isHidden = false
        } else {
            self.timeTableView.isHidden = true
            self.warningLabel.isHidden = true
            self.labelBackgroundView.isHidden = true
            self.leftLabel.isHidden = true
            self.rightLabel.isHidden = true
            self.tabBarController?.tabBar.isHidden = true
            self.destinationTableView.isHidden = false
            self.retryButton.isHidden = true
        }
    }
    
}

extension EngineeringViewController {
    func initializing() {
        
        //table view initializing
        self.timeTableView.delegate = self
        self.timeTableView.dataSource = self
        self.destinationTableView.delegate = self
        self.destinationTableView.dataSource = self
        self.searchTextField.delegate = self
        
        self.timeTableView.register(UINib(nibName: "TimeTableViewCell", bundle: nil), forCellReuseIdentifier: "TimeTableViewCell")
        self.destinationTableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: "DestinationTableViewCell")
        
        //view initializing
        if UIScreen.main.bounds.width < 350 {
            self.warningLabel.font = self.warningLabel.font.withSize(8)
            self.leftLabel.font = self.leftLabel.font.withSize(12)
            self.rightLabel.font = self.rightLabel.font.withSize(12)
            
        }
        
        self.labelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        self.labelBackgroundView.bottomAnchor.constraint(equalTo: self.timeTableView.topAnchor, constant: 0).isActive = true
        self.labelBackgroundView.leadingAnchor.constraint(equalTo: self.leftLabel.leadingAnchor, constant: -18).isActive = true
        self.labelBackgroundView.trailingAnchor.constraint(equalTo: self.rightLabel.trailingAnchor, constant: 28.5).isActive = true
        self.labelBackgroundView.heightAnchor.constraint(equalToConstant: 26).isActive = true
        self.labelBackgroundView.layer.cornerRadius = 6
        
        //better segmented control setup
        self.betterSegmentedControlSetup()
        
        // set up a Floaty(Floating Button)
        
        self.destinationTableView.isHidden = true
        
        
        self.destinationTableView.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([self.destinationTableView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 60)])
        self.destinationTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.destinationTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        self.destinationTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        

        
        //timeTableView refresh control initiailizing
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            self.timeTableView.refreshControl = refreshControl
        } else {
            self.timeTableView.addSubview(refreshControl)
        }
        
        let tapTextFieldGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.moveToSearchViewController(_:)))
        self.searchTextField.addGestureRecognizer(tapTextFieldGesture)
        
    }
    
    private func betterSegmentedControlSetup() {
        let control  = BetterSegmentedControl(
            frame: CGRect(x: 0, y: 0, width: 0, height: 0),
            segments: LabelSegment.segments(withTitles: ["시간", "목적지"],
                                            normalFont: UIFont(name: "NanumSquareOTFR", size: 12)!,
                                            normalTextColor: UIColor(red: 131/255, green: 131/255, blue: 131/255, alpha: 1),
                                            selectedFont: UIFont(name: "NanumSquareOTFR", size: 12)!,
                                            selectedTextColor: .black),
            index: 0,
            options: [.backgroundColor(UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)),
                      .indicatorViewBackgroundColor(UIColor(red: 246/255, green: 235/255, blue: 61/255, alpha: 1)),
                      .cornerRadius(12)]
        )
        control.addTarget(self, action: #selector(self.controlValueChanged(_:)), for: .valueChanged)
        view.addSubview(control)
        
        //Autolayout setting
        control.translatesAutoresizingMaskIntoConstraints = false
        //this code is for using safe area for y position
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([control.topAnchor.constraint(equalTo: margins.topAnchor, constant: 13)])
        
        control.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        control.widthAnchor.constraint(equalToConstant: 145.5).isActive = true
        control.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func setupFloaty() {
        self.floaty.buttonImage = UIImage(named: "icRetry")
        self.floaty.buttonColor = UIColor.clear
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.jsonParsing))
        self.floaty.addGestureRecognizer(tapGesture)
        self.view.addSubview(floaty)
        
//        self.floaty.translatesAutoresizingMaskIntoConstraints = false
//        self.floaty.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 28).isActive = true
//        self.floaty.bottomAnchor.constraint(equalTo: self.timeTableView.bottomAnchor, constant: 60).isActive = true
//        self.floaty.widthAnchor.constraint(equalToConstant: 49).isActive = true
//        self.floaty.heightAnchor.constraint(equalToConstant: 49).isActive = true
    }
    
    @objc func refreshData() {
        self.jsonParsing()
        self.refreshControl.endRefreshing()
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.searchTextField.resignFirstResponder()
    }
    
    @objc func moveToSearchViewController(_ sender: UITapGestureRecognizer) {
        print("move")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchVC") as! SearchViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: false)
    }
}


//Timer part
extension EngineeringViewController {
    func startTimer() {
        self.oneSecTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countdown), userInfo: nil, repeats: true)
        self.thirtySecTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.jsonParsing), userInfo: nil, repeats: true)
    }
    
    func endTimer() {
        self.oneSecTimer.invalidate()
        self.thirtySecTimer.invalidate()
    }
    
    @objc func countdown() {
        self.timeTableView.reloadData()
    }
    
}

extension EngineeringViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.searchTextField.text = nil
        self.isSearched = false
        self.jsonParsing()
        
        return false
    }
}


//customizing tableview cell
extension EngineeringViewController {
    //section part
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.timeTableView {
            return self.busType[section]
        } else {
            return self.destinations[section]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.timeTableView {
            return busType.count
        } else {
            return self.destinations.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.timeTableView {
            return 16.5
        } else {
            return 24
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableView == self.timeTableView {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont(name: "NanumSquareOTFB", size: 10)
            header.textLabel?.textColor = UIColor(white: 131/255, alpha: 1)
        } else {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont(name: "NanumSquareOTFR", size: 12)
            header.textLabel?.textColor = UIColor(white: 0, alpha: 1)
        }
    }
    
    //cell part
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.timeTableView {
            return self.sortedBuses[section].count
        } else {
            return self.destinationBus[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.timeTableView {
            return 51
        } else {
            return 38
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.timeTableView {
            tableView.deselectRow(at: indexPath, animated: false)
            let routeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "routeVC") as! RouteViewController
            routeViewController.busNumber = self.sortedBuses[indexPath.section][indexPath.row].no
            self.navigationController?.pushViewController(routeViewController, animated: true)
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.timeTableView {
            guard let cell = timeTableView.dequeueReusableCell(withIdentifier: "TimeTableViewCell", for: indexPath) as? TimeTableViewCell else {
                return UITableViewCell()
            }
            
            let bus: Bus = self.sortedBuses[indexPath.section][indexPath.row]

            cell.delegate = self
            cell.busNumber.text = bus.no
            cell.intervalTime.text = "\(bus.interval)분"
            
            if bus.type == "간선급행" {
                cell.busNumber.textColor = UIColor(red: 141/255, green: 20/255, blue: 191/255, alpha: 1)
            } else if bus.type == "광역" {
                cell.busNumber.textColor = UIColor(red: 191/255, green: 20/255, blue: 20/255, alpha: 1)
            }
            
            if indexPath.section == 0 {
                cell.favoritesButton.isHidden = true
            }
            
            for object in self.sortedBuses[0] {
                if object.no == bus.no {
                    cell.favoritesButton.setImage(UIImage(named: "icFavorPressed"), for: .normal)
                }
            }

            let arrivalTime = self.getArrivalTime(arrival: bus.arrival, start: bus.start, end: bus.end, interval: bus.interval)

            var arrivalTimeString: String?
            
            if arrivalTime < 0 {
                arrivalTimeString = "운행종료"
            } else if arrivalTime < 60 {
                arrivalTimeString = "곧 도착"
            } else {
                arrivalTimeString = "\(arrivalTime / 60)분 \(arrivalTime % 60)초"
            }

            cell.arrivalTime.text = arrivalTimeString

            return cell
            
        } else {
            let cell = self.destinationTableView.dequeueReusableCell(withIdentifier: "DestinationTableViewCell", for: indexPath) as! DestinationTableViewCell
            let test = destinationBus[indexPath.section][indexPath.row]
            var color: UIColor?
            
            switch indexPath.row {
            case 0:
                color = UIColor(red: 47/255, green: 96/255, blue: 206/255, alpha: 1)
            case 1:
                color = UIColor(red: 141/255, green: 20/255, blue: 191/255, alpha: 1)
            case 2:
                color = UIColor(red: 34/255, green: 194/255, blue: 68/255, alpha: 1)
            default:
                color = UIColor(red: 47/255, green: 96/255, blue: 206/255, alpha: 1)
            }
            
            cell.busNumber.text = test
            cell.busNumber.textColor = color
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func updateTableView() {
        self.sortBuses()
    }
    
}

//
//  SchoolViewController.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 29..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit
import KYDrawerController
import Floaty

class SchoolViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let subwayStation: [String] = ["지식정보단지", "인천대입구"]
    let jsonUrlString: String = "http://inucafeteria1.us.to:1337/arrivalinfoTo"
    var station: [Station] = []
    let bus = [["6", "6-1", "82", "6-2", "92", "909"], ["8", "16", "780", "909", "780-1", "908", "780-2"]]
    var sortedBus: [[Bus]] = [[], []]
    
    var refreshControl = UIRefreshControl()
    
    var floaty = Floaty()
    
    var oneSecTimer: Timer!
    var thirtySecTimer: Timer!
    
    let incheonUniv = "ICB164000395"
    let exit2 = "ICB164000373"
    let exit3 = "ICB164000403"
    let exit4 = "ICB164000380"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initializing()
        self.jsonParsing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimer()
    }
    
    @IBAction func touchUpRetryButton(_ sender: UIButton) {
        self.jsonParsing()
    }
    
    @IBAction func touchUpInforButton(_ sender: Any) {
        if let drawerController = tabBarController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    @objc func jsonParsing() {
        guard let url = URL(string: self.jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else { return }
            
            do{
                self.station = try JSONDecoder().decode([Station].self, from: data)
                print("bus of station arrival time download success!")
                self.sortBus()
            } catch let jsonErr {
                print(jsonErr)
            }
        }.resume()
    }
    
    func sortBus() {
        self.sortedBus = [[], []]
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.async {
            for object in self.station {
                if object.id != self.incheonUniv {
                    self.sortedBus[0].append(contentsOf: object.data)
                } else {
                    self.sortedBus[1].append(contentsOf: object.data)
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    

    func getArrivalTime(arrival: Int, interval: Int) -> Int {
        var second = Int((Double(arrival - Date().millisecondsSince1970) / 1000).rounded())
        
        while(true) {
            if second > 0 {
                return second
            } else {
                second = second + (interval * 60)
            }
        }
    }
}

extension SchoolViewController {
    func initializing() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "TimeTableViewCell", bundle: nil), forCellReuseIdentifier: "TimeTableViewCell")
        
        
        //timeTableView refresh control initiailizing
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        
//        self.setupFloaty()
        self.startTimer()
        
    }
    
    func setupFloaty() {
        self.floaty.buttonImage = UIImage(named: "icRetry")
        self.floaty.buttonColor = UIColor.clear
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.jsonParsing))
        self.floaty.addGestureRecognizer(tapGesture)
        self.view.addSubview(floaty)
        
        self.floaty.translatesAutoresizingMaskIntoConstraints = false
        self.floaty.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 28).isActive = true
        self.floaty.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 20).isActive = true
        self.floaty.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.floaty.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func refreshData() {
        self.jsonParsing()
        self.refreshControl.endRefreshing()
    }
    
    @objc func touchUpMapButton(_ sender: UIButton) {
        let mapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapVC")
        mapViewController.modalPresentationStyle = .overFullScreen
        mapViewController.modalTransitionStyle = .crossDissolve
        self.present(mapViewController, animated: true, completion: nil)
    }
    
    func startTimer() {
        self.oneSecTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countdown), userInfo: nil, repeats: true)
        self.thirtySecTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.jsonParsing), userInfo: nil, repeats: true)
    }
    
    func endTimer() {
        self.oneSecTimer.invalidate()
        self.thirtySecTimer.invalidate()
        print("timer end")
    }
    
    @objc func countdown() {
        self.tableView.reloadData()
    }
}

extension SchoolViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.subwayStation[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.subwayStation.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 23.5
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(white: 235/255, alpha: 1)
        
        let headerLabel: UILabel = UILabel(frame: CGRect(x: 15, y: 7, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "NanumSquareOTFR", size: 10)
        headerLabel.textColor = UIColor.black
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        
        headerView.addSubview(headerLabel)
        
        if section == 0 {
            let mapButton: UIButton = UIButton(frame: CGRect(x: self.tableView.bounds.size.width - 54, y: 8, width: 37, height: 9.5))
            mapButton.setTitle("지도보기", for: .normal)
            mapButton.titleLabel?.font = UIFont(name: "NanumSquareOTFR", size: 10)
            mapButton.setTitleColor(UIColor(red: 49/255, green: 121/255, blue: 189/255, alpha: 1), for: .normal)
            mapButton.addTarget(self, action: #selector(self.touchUpMapButton(_:)), for: .touchUpInside)
            headerView.addSubview(mapButton)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bus[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TimeTableViewCell", for: indexPath) as! TimeTableViewCell
        
        cell.favoritesButton.isHidden = true
        cell.arrivalTime.text = "운행종료"
        
        cell.busNumber.text = self.bus[indexPath.section][indexPath.row]
        
        cell.intervalTime.font = UIFont(name: "NanumSquareOTFR", size: 12)
        cell.intervalTime.textColor = UIColor(white: 126/255, alpha: 1)
        cell.intervalTime.text = "2번출구"
        
        if indexPath.section == 0 {
            if indexPath.row == 4 {
                cell.busNumber.textColor = UIColor(red: 17/255, green: 191/255, blue: 25/255, alpha: 1)
            }
            if indexPath.row == 5 {
                cell.busNumber.textColor = UIColor(red: 148/255, green: 17/255, blue: 191/255, alpha: 1)
            }
            
            switch indexPath.row {
            case 0:
                cell.intervalTime.text = "2번출구"
            case 1, 2:
                cell.intervalTime.text = "3번출구"
            case 3, 4, 5:
                cell.intervalTime.text = "4번출구"
            default:
                print("out of range")
            }
            
            for object in self.sortedBus[0] {
                if self.bus[indexPath.section][indexPath.row] == object.no {
                    let second = self .getArrivalTime(arrival: object.arrival, interval: object.interval)
                    
                    if second < 60 {
                        cell.arrivalTime.text = "곧 도착"
                    } else {
                        cell.arrivalTime.text = "\(second / 60)분 \(second % 60)초"
                    }
                    
                }
            }
        } else {
            if indexPath.row == 3 || indexPath.row == 5 {
                cell.busNumber.textColor = UIColor(red: 148/255, green: 17/255, blue: 191/255, alpha: 1)
            }
            
            for object in self.sortedBus[1] {
                if self.bus[indexPath.section][indexPath.row] == object.no {
                    let second = self.getArrivalTime(arrival: object.arrival, interval: object.interval)
                    if second < 60 {
                        cell.arrivalTime.text = "곧 도착"
                    } else {
                        cell.arrivalTime.text = "\(second / 60)분 \(second % 60)초"
                    }
                }
            }
        }
        
        cell.arrivalTime.sizeToFit()
        cell.selectionStyle = .none
        
        return cell
    }
}

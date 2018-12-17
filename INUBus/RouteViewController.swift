//
//  RouteViewController.swift
//  INUBus
//
//  Created by LEE JUNSANG on 2018. 8. 18..
//  Copyright © 2018년 zunzun. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var busNumber: String = ""
    let jsonUrlString: String = "http://inucafeteria1.us.to:1337/getNodes/"
    

    var busStops: [String] = []
    var turnStop: String?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "RouteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RouteCollectionViewCell")
        self.collectionView.register(UINib(nibName: "FirstRouteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FirstRouteCollectionViewCell")
        
        jsonParsing()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func jsonParsing() {
        guard let url = URL(string: "\(jsonUrlString)\(busNumber)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else { return }
            
            do {
                let busRoute = try JSONDecoder().decode(BusRoute.self, from: data)
                
                let group = DispatchGroup()
                
                group.enter()
                DispatchQueue.main.async {
                    self.busStops = busRoute.nodeList
                    self.turnStop = busRoute.turnNode
                    self.index = self.busStops.index(of: self.turnStop!)
                    self.busStops.insert(self.turnStop!, at: self.index!)
                    group.leave()
                }

                group.notify(queue: .main) {
                    self.collectionView.reloadData()
                }
                
                print("bus route download success")
            } catch let jsonErr {
                print(jsonErr)
            }
            }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchUpBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.busStops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstRouteCollectionViewCell", for: indexPath) as! FirstRouteCollectionViewCell
            cell.busStopLabel.text = busStops[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteCollectionViewCell", for: indexPath) as! RouteCollectionViewCell
            if indexPath.row <= self.index! {
            cell.rightBusStopLabel.text = busStops[indexPath.row]
            } else if indexPath.row == (self.index! + 1) {
                cell.turnLabel.isHidden = false
                cell.leftBusStopLabel.text = busStops[indexPath.row]
            } else {
                cell.leftBusStopLabel.text = busStops[indexPath.row]
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: view.frame.width, height: 17)
        } else if indexPath.row == (self.index! + 1) {
            return CGSize(width: view.frame.width, height: 73)
        } else {
            return CGSize(width: view.frame.width, height: 57)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//var busStops: [String] = [
//    "인천대학교공과대학",
//    "인천대학교자연과학대학",
//    "인천대정문",
//    "송도더샵마스터뷰23단지",
//    "인천대입구역",
//    "인천가톨릭대",
//    "미추홀공원",
//    "송도컨벤시아",
//    "송도1동주민센터",
//    "해양경찰청",
//    "송도풍림아이원2단지",
//    "송도풍림아이원2단지",
//    "금호아파트",
//    "신송고등학교",
//    "한진아파트",
//    "동막역(1번출구)",
//    "풍림2차아파트",
//    "인천뷰티예술고등학교",
//    "서면초등학교",
//    "한양2차아파트",
//    "나사렛국제병원앞",
//    "동춘마을아파트",
//    "여성의광장",
//    "복지회관",
//    "송도라마다호텔앞",
//    "송도유원지(도로교통공단)",
//    "백산아파트",
//    "원흥아파트",
//    "현대3차아파트",
//    "현대아파트",
//    "현대4차아파트",
//    "서해아파트",
//    "축현초등학교.인천시립박물관",
//    "호불사입구",
//    "송도재래시장",
//    "송도역",
//    "옥련고개",
//    "옥련여고(인천해양경찰서)",
//    "조개고개",
//    "동양화학",
//    "인하대역(7번출구)",
//    "인하대정문",
//    "장미아파트",
//    "학익사거리(동아풍림아파트)",
//    "학익시장",
//    "학익2동행정복지센터",
//    "제운사거리",
//    "용일사거리",
//    "석락아파트",
//    "새안의원",
//    "국민건강보험남부지사",
//    "재흥시장",
//    "(구)시민회관사거리",
//    "시민공원(문화창작지대)역",
//    "석바위",
//    "석바위시장역",
//    "인천교회",
//    "현대아파트",
//    "극동.금호아파트",
//    "인천시청후문",
//    "석천사거리역",
//    "힐캐슬프라자",
//    "모래내시장역(4번출구)",
//    "모래내시장역(3번출구)",
//    "효성상아아파트",
//    "현광아파트",
//    "만수주공정문",
//    "만수주공4단지",
//    "만수4동주민센터",
//    "숭덕여중고입구",
//    "아주아파트",
//    "정광아파트.만수주공11단지",
//    "공작아파트",
//    "수현마을",
//    "인천대공원",
//    "무내미마을",
//    "충성아파트",
//    "근로복지공단인천병원",
//    "구산사거리",
//    "송내역",
//    "구산사거리",
//    "근로복지공단인천병원",
//    "무내미마을",
//    "수현마을",
//    "정광아파트.만수주공11단지",
//    "아주아파트",
//    "숭덕여중고입구",
//    "만수4동주민센터",
//    "만수주공4단지",
//    "만수주공정문",
//    "만수역",
//    "현광아파트(호산부인과)",
//    "효성상아아파트",
//    "모래내시장역(2번출구)",
//    "모래내시장역(1번출구)",
//    "힐캐슬프라자",
//    "석천사거리역",
//    "인천시청후문",
//    "극동.금호아파트",
//    "현대아파트",
//    "인천교회",
//    "석바위시장역",
//    "석바위",
//    "주안현대아파트",
//    "(구)시민회관사거리",
//    "재흥시장",
//    "신기사거리",
//    "새안의원",
//    "용일사거리",
//    "제운사거리",
//    "학익2동행정복지센터",
//    "학익시장",
//    "학익사거리(동아풍림아파트)",
//    "장미아파트",
//    "인하대정문",
//    "인하대역(1번출구)",
//    "동양화학",
//    "조개고개",
//    "옥련여고(인천해양경찰서)",
//    "옥련고개",
//    "옥련동주민센터",
//    "송도재래시장",
//    "호불사입구",
//    "축현초등학교.인천시립박물관",
//    "서해아파트",
//    "현대4차아파트",
//    "현대5차아파트",
//    "현대3차아파트",
//    "원흥아파트",
//    "백산아파트",
//    "송도유원지(도로교통공단)",
//    "송도라마다호텔앞",
//    "복지회관",
//    "여성의광장",
//    "태평아파트",
//    "건영아파트",
//    "대동아파트",
//    "무지개아파트",
//    "인천뷰티예술고등학교",
//    "풍림2차아파트",
//    "동막역(3번출구)",
//    "성지아파트",
//    "신송고등학교",
//    "송도풍림아이원4단지",
//    "송도풍림아이원1단지",
//    "송도풍림아이원2단지",
//    "해양경찰청",
//    "송도더샵퍼스트월드(동문)",
//    "송도더샵퍼스트월드D동",
//    "송도컨벤시아",
//    "인천가톨릭대",
//    "인천대입구역",
//    "송도더샵마스터뷰23단지",
//    "인천대정문",
//    "인천대학교자연과학대학",
//    "인천대학교공과대학"
//]

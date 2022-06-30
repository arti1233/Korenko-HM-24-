//
//  ListViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import Foundation
import RealmSwift
import UIKit

class ListViewController: UIViewController {
    static let key = "ListViewController"
    let realm = try! Realm()
    var items: Results<RequestListRealmData>!
    var itemsWeather: Results<WeatherDataRealm>!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: TableViewCellForListReqest.key, bundle: nil), forCellReuseIdentifier: TableViewCellForListReqest.key)
        
        items = realm.objects(RequestListRealmData.self)
        itemsWeather = realm.objects(WeatherDataRealm.self)
        tableView.reloadData()
    }
    

}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count != 0 {
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellForListReqest.key) as? TableViewCellForListReqest else { return UITableViewCell() }
        let item = items[indexPath.row]
        guard let weather = item.weather else { return UITableViewCell() }
        let time = Int(item.time.timeIntervalSince1970)
        cell.informationLabel.text = "lat = \(item.lat), lot = \(item.lon), time = \(time), temp = \(weather.temp), feelsLike = \(weather.feelsLike)"
        cell.iconView.image = getIconImage(iconId: weather.icon)
        return cell
    }
    
}

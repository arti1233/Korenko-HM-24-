//
//  ListViewController1.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 20.07.22.
//

import Foundation
import RealmSwift
import UIKit

class ListViewController: UIViewController {
    static let key = "ListViewController"
    var items: Results<RequestListRealmData>!
    var notificationToken: NotificationToken?
    
    @IBOutlet weak var tableView: UITableView!
    private var realmProvider: RealmServiceProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realmProvider = RealmService()
        
        items = realmProvider.reloadListRequest()
        
        notificationToken = items.observe{ [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.performBatchUpdates {
                    self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),with: .automatic)
                }
            case .error(_):
                fatalError()
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: TableViewCellForListReqest.key, bundle: nil), forCellReuseIdentifier: TableViewCellForListReqest.key)
        
    }
    
    deinit{
        guard let token = notificationToken else { return }
        token.invalidate()
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
        cell.coordinateLabel.text = "\("lat".localize) = \(item.lat), \("lot".localize) = \(item.lon)"
        cell.timeLabel.text = "\("Data with".localize) \((item.isLocation).locationDescription.localize), \("time".localize) = \(time.timeHHmm)"
        cell.tempLabel.text = "\("temp".localize) = \(Int(weather.temp)) C, \("feelsLike".localize) = \(Int(weather.feelsLike)) C"
        cell.weatherDescriptionLabel.text = weather.descriptionWeather
        cell.iconView.image = weather.icon.image
        return cell
    }
}


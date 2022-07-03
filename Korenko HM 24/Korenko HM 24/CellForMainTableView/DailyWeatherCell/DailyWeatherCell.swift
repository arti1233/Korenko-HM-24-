//
//  DailyWeatherCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import UIKit

class DailyWeatherCell: UITableViewCell {

    static let key = "DailyWeatherCell"
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
 
    
    var dailyWeather: [Daily]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: DailyWeatherForTableCell.key, bundle: nil), forCellReuseIdentifier: DailyWeatherForTableCell.key)
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    
    
}

extension DailyWeatherCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let values = dailyWeather else { return 0 }
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyWeatherForTableCell.key) as? DailyWeatherForTableCell,
              let weatherData = dailyWeather else { return UITableViewCell() }
            
        cell.reloadWeatherData(weatherData: weatherData[indexPath.row])
        return cell
        
        }
        
    }

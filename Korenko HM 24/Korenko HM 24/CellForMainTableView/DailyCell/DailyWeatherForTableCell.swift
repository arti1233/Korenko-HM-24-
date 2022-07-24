//
//  DailyWeatherForTableCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import UIKit

class DailyWeatherForTableCell: UITableViewCell {

    static let key = "DailyWeatherForTableCell"
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    var temperature = String()
    var daily: Daily?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        
        
    }

    func changeMetricTemperature(isMetric: UnitsOfMeasurement) {
        if isMetric == UnitsOfMeasurement.metric {
            temperature = "C"
        } else {
            temperature = "F"
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func reloadWeatherData(weatherData: Daily) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self,
                  let weather = weatherData.weather.first else { return }
            let icon = weather.icon.image
            DispatchQueue.main.async {
                self.timeLabel.text = weatherData.dt.timeEEEE
                self.iconView.image = icon
                self.tempLabel.text = "\(Int(weatherData.temp.min)) - \(Int(weatherData.temp.max)) \((self.temperature).localize)"
            }
        }
    }
}

//
//  CurrentWeatherCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 28.06.22.
//

import UIKit

class CurrentWeatherCell: UITableViewCell {

    static let key = "CurrentWeatherCell"
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cloudlyLabel: UILabel!
    @IBOutlet weak var speedWindLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    var temperature: String!
    var isFullTime: Bool!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    func changeParams(isMetric: UnitsOfMeasurement, isTimeFormat24: Bool) {
        temperature = isMetric == UnitsOfMeasurement.metric ? "C" : "F"
        isFullTime = isTimeFormat24
    }
    
  
    
    
    
    func reloadWeatheData(weatherData: WeatherData) {
        DispatchQueue.main.async { [weak self] in
            let weather = weatherData.current
            guard let weatherDescription = weather.weather.first,
                  let self = self,
                  let isFullTime = self.isFullTime,
                  let temperature = self.temperature else { return }
            self.timeLabel.text = weather.dt.timeHHmmDDMMYYYY(isTimeFormat24: isFullTime)
            self.cityLabel.text = weatherData.timezone
            self.weatherLabel.text = weatherDescription.weatherDescription
            self.tempLabel.text = "\(Int(weather.temp)) \((temperature).localize)"
            self.cloudlyLabel.text = "\(weather.clouds) %"
            self.speedWindLabel.text = "\(Int(weather.windSpeed)) \("m/s".localize)"
            self.sunriseLabel.text = "\(weather.sunrise.timeHHmm(isTimeFormate24: isFullTime))"
            self.sunsetLabel.text = "\(weather.sunset.timeHHmm(isTimeFormate24: isFullTime))"
        }
    }
}

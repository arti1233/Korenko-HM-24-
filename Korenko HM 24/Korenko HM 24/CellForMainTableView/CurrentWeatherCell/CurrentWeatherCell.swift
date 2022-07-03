//
//  CurrentWeatherCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 28.06.22.
//

import UIKit

class CurrentWeatherCell: UITableViewCell {

    static let key = "CurrentWeatherCell"
    
    @IBOutlet weak var nameCityLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!

        
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 20
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    func reloadWeatheData(weatherData: WeatherData) {
        DispatchQueue.main.async { [weak self] in
            let weather = weatherData.current
            guard let weatherDescription = weather.weather.first,
                  let self = self else { return }
            self.nameCityLabel.text = weatherData.timezone
            self.tempLabel.text = "\(Int(weather.temp)) C"
            self.weatherDescriptionLabel.text = String(weatherDescription.weatherDescription.description)
            self.iconView.image = weatherDescription.icon.image
        }
    }
}

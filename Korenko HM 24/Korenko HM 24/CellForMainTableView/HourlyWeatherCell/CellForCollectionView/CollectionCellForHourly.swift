//
//  CollectionCellForHourly.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import UIKit

class CollectionCellForHourly: UICollectionViewCell {

    static let key = "CollectionCellForHourly"
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    var temperature: String!
    var isFullTime: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    

    func changeParams(isMetric: UnitsOfMeasurement, isTimeFormat24: Bool) {
        temperature = isMetric == UnitsOfMeasurement.metric ? "C" : "F"
        isFullTime = isTimeFormat24
    }

    
    func reloadWeatherData(weatherData: Hourly) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self,
                  let weather = weatherData.weather.first,
                  let temperature = self.temperature,
                  let isFullTime = self.isFullTime else { return }
            let icon = weather.icon.image
            DispatchQueue.main.async {
                self.iconImageView.image = icon
                self.timeLabel.text = weatherData.dt.timeHHmm(isTimeFormate24: isFullTime)
                self.tempLabel.text = "\(Int(weatherData.temp)) \((temperature).localize)"
            }
        }
    }
}

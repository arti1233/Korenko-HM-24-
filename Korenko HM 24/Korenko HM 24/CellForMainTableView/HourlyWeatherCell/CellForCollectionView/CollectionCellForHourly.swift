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
    
    var timeFormat24 = Bool()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func changeParams(isTimeFormat24: Bool) {
        if isTimeFormat24 {
            timeFormat24 = isTimeFormat24
        } else {
            timeFormat24 = isTimeFormat24
        }
    }
    

    
    func reloadWeatherData(weatherData: Hourly) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self,
                  let weather = weatherData.weather.first else { return }
            let icon = weather.icon.image
            DispatchQueue.main.async {
                self.iconImageView.image = icon
                self.timeLabel.text = weatherData.dt.timeHHmm(isTimeFormate24: self.timeFormat24)
                self.tempLabel.text = "\(Int(weatherData.temp)) C"
            }
        }
    }
}

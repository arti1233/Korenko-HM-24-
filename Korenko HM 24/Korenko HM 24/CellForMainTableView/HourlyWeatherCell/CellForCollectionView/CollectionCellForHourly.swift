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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    
    func reloadWeatherData(weatherData: Hourly) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let weather = weatherData.weather.first else { return }
            self.timeLabel.text = weatherData.dt.timeHHmm
            self.iconImageView.image = weather.icon.image
            self.tempLabel.text = "\(Int(weatherData.temp)) C"
        }
    }
}

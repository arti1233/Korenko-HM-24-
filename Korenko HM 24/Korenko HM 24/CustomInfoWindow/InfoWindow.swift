//
//  InfoWindow.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 13.07.22.
//

import UIKit

class InfoWindow: UITableViewCell {

    static let key = "InfoWindow"
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humiditiLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func reloadMainView(weather: Current) {
        guard let weatherDescription = weather.weather.first else { return }
        let icon = weatherDescription.icon.image
        self.iconImage.image = icon
        self.tempLabel.text = "\(weather.temp) C"
        self.humiditiLabel.text = "\(weather.humidity) %"
    }
    
    
    
}

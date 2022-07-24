//
//  HourlyWeatherCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import UIKit

class HourlyWeatherCell: UITableViewCell {
    
    static let key = "HourlyWeatherCell"
    @IBOutlet weak var collectionView: UICollectionView!
    var weatherHourly: [Hourly]?
    var timeFormat24 = Bool()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: CollectionCellForHourly.key, bundle: nil), forCellWithReuseIdentifier: CollectionCellForHourly.key)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension HourlyWeatherCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let weather = weatherHourly else { return 0 }
        return weather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCellForHourly.key, for: indexPath) as? CollectionCellForHourly,
              let weather = weatherHourly else { return UICollectionViewCell() }
        cell.layer.cornerRadius = 20
        cell.reloadWeatherData(weatherData: weather[indexPath.row])
        cell.timeFormat24 = timeFormat24
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}

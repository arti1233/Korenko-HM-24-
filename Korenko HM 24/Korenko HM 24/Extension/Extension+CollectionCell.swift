//
//  Extension+CollectionCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 30.06.22.
//

import Foundation
import UIKit


extension UICollectionViewCell {
  
    // запрос для получения картинки
    func getIconImage(iconId: String) -> UIImage {
        let api = "https://openweathermap.org/img/wn/\(iconId)@2x.png"
        guard let apiURL = URL(string: api) else { return UIImage() }
        let data = try! Data(contentsOf: apiURL)
        guard let image = UIImage(data: data) else { return UIImage() }
        return image
    }

    // конвертор времени
    func confertUnixTypeToNormal(time: Double, typeTime: String) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = typeTime //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}

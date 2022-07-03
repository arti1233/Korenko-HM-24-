//
//  Extension+ViewControler.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 30.06.22.
//

import Foundation
import UIKit

// запрос для получения картинки
extension String {
    var image: UIImage {
        let api = "https://openweathermap.org/img/wn/\(self)@2x.png"
        guard let apiURL = URL(string: api) else { return UIImage() }
        let data = try! Data(contentsOf: apiURL)
        guard let image = UIImage(data: data) else { return UIImage() }
        return image
    }
}

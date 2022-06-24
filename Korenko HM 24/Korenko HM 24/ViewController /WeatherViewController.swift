//
//  ViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 19.06.22.
//

import UIKit

enum UnitsOfMeasurement {
    case metric
    case imperial
    
    var description: String {
        switch self {
        case .metric:
            return "metric"
        case .imperial:
            return "imperial"
        }
    }
}


class WeatherViewController: UIViewController {

    var nameCity = "Minsk"
    var measurement = UnitsOfMeasurement.metric
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }


    

    
}


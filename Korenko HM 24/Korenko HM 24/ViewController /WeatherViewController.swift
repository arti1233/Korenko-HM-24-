//
//  ViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 19.06.22.
//

import UIKit

class WeatherViewController: UIViewController {

    private var apiProvider: RestAPIProviderProtocol!
    
    
    
    
    var weatherData: WeatherData?
    var nameCity = "Minsk"
    var measurement = UnitsOfMeasurement.metric
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiProvider = AlamofireProvider()
        
        
        
        getCoordinatesByName(name: nameCity)
        
        
    }


// MARK: Metods
    
    func getCoordinatesByName(name: String) {
        apiProvider.getCoordinateByName(name: name) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                if let city = value.first {
                    self.getWeatherByCoordinates(city: city, measurement: self.measurement.description)
                    print(value)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func getWeatherByCoordinates(city: Geocoding, measurement: String) {
        apiProvider.getWeatherForCityCoordinates(lat: city.lat, lon: city.lon, measurement: measurement) { result in
            switch result {
            case .success(let value):
                self.weatherData = value
                print(value.current)
            case .failure(let error):
                print(error)
            }
        }
    }
}


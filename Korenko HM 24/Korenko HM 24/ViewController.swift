//
//  ViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 19.06.22.
//

import UIKit

class ViewController: UIViewController {

    let APIKey = "52e0cef2e795eb013506ecb52fb1c280"
    var nameCity = "Minsk"
    var measurement = UnitsOfMeasurement.metric
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestToServer(nameCity: nameCity, measurement: measurement)
        
    }


    
    
// MARK: Metods
    
    // Запрос для получения данных
    
    func requestToServer(nameCity: String, measurement: UnitsOfMeasurement) {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(nameCity)&appid=\(APIKey)\(measurement.description)") {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data = data {
                    let weather = try! JSONDecoder().decode(WeatherData.self, from: data)
                    print(weather.temperature)
                }
            }
            dataTask.resume()
        }
    }
    
    
    
    
}


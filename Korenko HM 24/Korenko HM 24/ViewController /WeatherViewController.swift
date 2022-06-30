//
//  ViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 19.06.22.
//

import UIKit
import RealmSwift


class WeatherViewController: UIViewController {

    private var apiProvider: RestAPIProviderProtocol!

// MARK: IBOutlet
    
    @IBOutlet weak var mainTableView: UITableView!
    var cityName = String()
    var weatherData: WeatherData?
    var measurement = UnitsOfMeasurement.metric
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiProvider = AlamofireProvider()
        
        mainTableView.dataSource = self
        mainTableView.delegate = self
    
        mainTableView.register(UINib(nibName: CurrentWeatherCell.key, bundle: nil), forCellReuseIdentifier: CurrentWeatherCell.key)
        mainTableView.register(UINib(nibName: HourlyWeatherCell.key, bundle: nil), forCellReuseIdentifier: HourlyWeatherCell.key)
        mainTableView.register(UINib(nibName: DailyWeatherCell.key, bundle: nil), forCellReuseIdentifier: DailyWeatherCell.key)
    }

    @IBAction func choseCityButton(_ sender: Any) {
        choseCityAlertController()
    }
    
    
    
    
    
// MARK: METODS
    
    // Chose City alertController
    
    func choseCityAlertController() {
        let alertController = UIAlertController(title: "Chose city", message: "Please, enter the name of the city", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name city"
        }
        let okButton = UIAlertAction(title: "Enter", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?[0],
                  let text = textField.text,
                  let self = self else { return }
            let textWithoutWhitespace = text.trimmingCharacters(in: .whitespaces)
            self.getCoordinatesByName(name: textWithoutWhitespace)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    fileprivate func getCoordinatesByName(name: String) {
        apiProvider.getCoordinateByName(name: name) { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .success(let value):
                    if let city = value.first {
                        self.getWeatherByCoordinates(city: city)
                    }
                case .failure(let error):
                    self.errorAlertController(error: error.localizedDescription)
                }
            }
        }
        
        private func getWeatherByCoordinates(city: Geocoding) {
            apiProvider.getWeatherForCityCoordinates(lat: city.lat, lon: city.lon, measurement: measurement.description) { result in
                switch result {
                case .success(let value):
                    self.weatherData = value
                    self.addObjectInRealm(weather: value)
                    self.mainTableView.reloadData()
                case .failure(let error):
                    self.errorAlertController(error: error.localizedDescription)
                }
            }
        }
    
    
    func errorAlertController(error: String) {
        let alrtController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Repeat", style: .cancel)
        alrtController.addAction(okButton)
        present(alrtController, animated: true)
    }
    

    
}
   
extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentCell = mainTableView.dequeueReusableCell(withIdentifier: CurrentWeatherCell.key) as? CurrentWeatherCell,
              let weather = weatherData else { return UITableViewCell()}
        currentCell.reloadWeatheData(weatherData: weather)
        
        
        guard let hourlyCell = mainTableView.dequeueReusableCell(withIdentifier: HourlyWeatherCell.key) as? HourlyWeatherCell else { return UITableViewCell() }
        hourlyCell.weatherHourly = weather.hourly
        
        guard let dailyCell = mainTableView.dequeueReusableCell(withIdentifier: DailyWeatherCell.key) as? DailyWeatherCell else { return UITableViewCell() }
        dailyCell.dailyWeather = weather.daily
        
        if indexPath.row == 0 {
            return currentCell
        } else if indexPath.row == 1 {
            return hourlyCell
        } else if indexPath.row == 2 {
            return dailyCell
        } else {
            return UITableViewCell()
        }
    }
    
    
}

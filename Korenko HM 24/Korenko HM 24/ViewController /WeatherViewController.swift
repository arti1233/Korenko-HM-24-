//
//  ViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 19.06.22.
//

import UIKit
import RealmSwift

enum SectionTableView: Int {
    case current = 0
    case hourly = 1
    case daily = 2
    case changeCity = 3
    
    var description: String {
        switch self {
        case .current:
            return "CURRENT FORECAST"
        case .hourly:
            return "HOURLY FORECAST"
        case .daily:
            return "8-DAY FORECAST"
        case .changeCity:
            return "CHOOSE CITY"
        }
    }
}



class WeatherViewController: UIViewController {

    private var apiProvider: RestAPIProviderProtocol!

// MARK: IBOutlet
    
    @IBOutlet weak var mainTableView: UITableView!
    var cityName = String()
    var weatherData: WeatherData?
    var weatherDataHourly: [Hourly]?
    var weatherDataCurrent: Current?
    var weatherDataDaily: [Daily]?
    var measurement = UnitsOfMeasurement.metric
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationIdentifier = "WeatherNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiProvider = AlamofireProvider()
        mainTableView.dataSource = self
        mainTableView.delegate = self
        
        
        mainTableView.register(UINib(nibName: CurrentWeatherCell.key, bundle: nil), forCellReuseIdentifier: CurrentWeatherCell.key)
        mainTableView.register(UINib(nibName: HourlyWeatherCell.key, bundle: nil), forCellReuseIdentifier: HourlyWeatherCell.key)
        mainTableView.register(UINib(nibName: DailyWeatherForTableCell.key, bundle: nil), forCellReuseIdentifier: DailyWeatherForTableCell.key)
        mainTableView.register(UINib(nibName: ButtonCell.key, bundle: nil), forCellReuseIdentifier: ButtonCell.key)
        getCoordinatesByName(name: "moscow")
        
        
    
        
        
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
                    guard let weather = value.current.weather.first else { return }
                    self.weatherData = value
                    self.addObjectInRealm(weather: value)
                    self.getNotificationForWeather(weatherData: value.hourly)
                    self.getImageForWeatherView(weather: weather.id)
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
    
    
    // метод проверки почасовой погоды
    func getNotificationForWeather(weatherData: [Hourly]) {
        for weather in weatherData.dropFirst() {
            var counter = 0
            guard let weatherId = weather.weather.first, counter == 0 else { return }
            switch weatherId.id {
            case 200...232:
                addNotification(weather: weatherId.main.rawValue, time: weather.dt.getTimeForNotification)
                counter += 1
                break
            case 500...531:
                addNotification(weather: weatherId.main.rawValue, time: weather.dt.getTimeForNotification)
                counter += 1
                break
            case 600...622:
                addNotification(weather: weatherId.main.rawValue, time: weather.dt.getTimeForNotification)
                counter += 1 
                break
            default:
                break
            }
        }
    }
    
    // метод добавления уведомления
    func addNotification(weather: String, time: DateComponents) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        let content = UNMutableNotificationContent()
        content.title = "Warning"
        content.body = "\(weather) will be in 30 minute!"
        content.sound = UNNotificationSound.default
        let triger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: triger)
        notificationCenter.add(request) { error in
            print(error?.localizedDescription)
        }
    }
    
    func getImageForWeatherView(weather: Int) {
           switch weather {
           case 500...531:
               view.backgroundColor = UIColor(patternImage: UIImage(named: "Rain")!)
           case 800:
               view.backgroundColor = UIColor(patternImage: UIImage(named: "Vilage")!)
           case 801...804:
               view.backgroundColor = UIColor(patternImage: UIImage(named: "Cloudly")!)
           case 210...232:
               view.backgroundColor = UIColor(patternImage: UIImage(named: "groza")!)
           default:
               view.backgroundColor = UIColor(patternImage: UIImage(named: "Sun")!)
           }
       }
}
   
// MARK: TableView extension
extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let weather = weatherData else { return 0}
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return weather.daily.count
        case 3:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentCell = mainTableView.dequeueReusableCell(withIdentifier: CurrentWeatherCell.key) as? CurrentWeatherCell,
              let weather = weatherData else { return UITableViewCell()}

        guard let hourlyCell = mainTableView.dequeueReusableCell(withIdentifier: HourlyWeatherCell.key) as? HourlyWeatherCell else { return UITableViewCell() }
       
        guard let dailyCell = mainTableView.dequeueReusableCell(withIdentifier: DailyWeatherForTableCell.key) as? DailyWeatherForTableCell else { return UITableViewCell() }
       
        guard let buttonCell = mainTableView.dequeueReusableCell(withIdentifier: ButtonCell.key) as? ButtonCell else { return UITableViewCell() }
    
        switch indexPath.section{
        case 0:
            currentCell.reloadWeatheData(weatherData: weather)
            return currentCell
        case 1:
            hourlyCell.weatherHourly = weather.hourly
            return hourlyCell
        case 2:
            dailyCell.reloadWeatherData(weatherData: weather.daily[indexPath.row])
            return dailyCell
        case 3:
            return  buttonCell
        default:
            return  UITableViewCell()
        }
    }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let key = SectionTableView(rawValue: section) else { return ""}
        return key.description
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let key = SectionTableView(rawValue: indexPath.section) else { return }
        
        if key == .changeCity {
            choseCityAlertController()
        }
    }
    
    
    
}

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
    
    var description: String {
        switch self {
        case .current:
            return "CURRENT FORECAST"
        case .hourly:
            return "HOURLY FORECAST"
        case .daily:
            return "7-DAY FORECAST"
        }
    }
}

class WeatherViewController: UIViewController {

    private var apiProvider: RestAPIProviderProtocol!

// MARK: IBOutlet
    
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var mainTableView: UITableView!
    let myRefreshControll: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(rehresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    var cityName = "moscow"
    var weatherData: WeatherData?
    var weatherDataHourly: [Hourly]?
    var weatherDataCurrent: Current?
    var weatherDataDaily: [Daily]?
    var measurement = UnitsOfMeasurement.metric
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationIdentifier = "WeatherNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerView.hidesWhenStopped = true
        spinnerView.startAnimating()
        
        mainTableView.refreshControl = myRefreshControll
        
        apiProvider = AlamofireProvider()
        mainTableView.dataSource = self
        mainTableView.delegate = self
        
        
        mainTableView.register(UINib(nibName: CurrentWeatherCell.key, bundle: nil), forCellReuseIdentifier: CurrentWeatherCell.key)
        mainTableView.register(UINib(nibName: HourlyWeatherCell.key, bundle: nil), forCellReuseIdentifier: HourlyWeatherCell.key)
        mainTableView.register(UINib(nibName: DailyWeatherForTableCell.key, bundle: nil), forCellReuseIdentifier: DailyWeatherForTableCell.key)
        mainTableView.register(UINib(nibName: ButtonCell.key, bundle: nil), forCellReuseIdentifier: ButtonCell.key)
        getCoordinatesByName(name: cityName)
    
    }
    
// MARK: METODS
    
    @objc private func rehresh(sender: UIRefreshControl){
        getCoordinatesByName(name: cityName)
        sender.endRefreshing()
    }
    
    
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
            self.spinnerView.hidesWhenStopped = true
            self.spinnerView.startAnimating()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    fileprivate func getCoordinatesByName(name: String) {
        apiProvider.getCoordinateByName(name: name) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.cityName = name
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
                    self.weatherDataDaily = Array(value.daily.dropFirst())
                    DispatchQueue.global().async { [weak self] in
                        guard let self = self else { return }
                        self.addObjectInRealm(weather: value)
                        self.getNotificationForWeather(weatherData: value.hourly)
                        let imageBackground = self.getImageForWeatherView(weather: weather.id)
                        DispatchQueue.main.async {
                            self.view.backgroundColor = imageBackground
                            self.mainTableView.reloadData()
                            self.spinnerView.stopAnimating()
                        }
                    }
                case .failure(let error):
                    self.errorAlertController(error: error.localizedDescription)
                    self.spinnerView.stopAnimating()
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
    
    func getImageForWeatherView(weather: Int) -> UIColor {
           switch weather {
           case 500...531:
               guard let image = UIImage(named: "Rain") else { return UIColor()}
               return UIColor(patternImage: image)
           case 800:
               guard let image = UIImage(named: "Vilage") else { return UIColor()}
               return UIColor(patternImage: image)
           case 801...804:
               guard let image = UIImage(named: "Cloudly") else { return UIColor()}
               return UIColor(patternImage: image)
           case 210...232:
               guard let image = UIImage(named: "groza") else { return UIColor()}
               return UIColor(patternImage: image)
           default:
               guard let image = UIImage(named: "Sun") else { return UIColor()}
               return UIColor(patternImage: image)
           }
       }
}
   
// MARK: TableView extension
extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if weatherData == nil {
            return 0
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let weatherDaily = weatherDataDaily else { return 0}
        
        
        switch section {
        case 0, 1:
            return 1
        case 2:
            return weatherDaily.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentCell = mainTableView.dequeueReusableCell(withIdentifier: CurrentWeatherCell.key) as? CurrentWeatherCell,
              let weather = weatherData else { return UITableViewCell()}

        guard let hourlyCell = mainTableView.dequeueReusableCell(withIdentifier: HourlyWeatherCell.key) as? HourlyWeatherCell else { return UITableViewCell() }
       
        guard let dailyCell = mainTableView.dequeueReusableCell(withIdentifier: DailyWeatherForTableCell.key) as? DailyWeatherForTableCell,
              let weatherDaily = weatherDataDaily  else { return UITableViewCell() }
       
        
        switch indexPath.section{
        case 0:
            currentCell.reloadWeatheData(weatherData: weather)
            return currentCell
        case 1:
            hourlyCell.weatherHourly = weather.hourly
            return hourlyCell
        case 2:
            dailyCell.reloadWeatherData(weatherData: weatherDaily[indexPath.row])
            return dailyCell
        default:
            return  UITableViewCell()
        }
    }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let key = SectionTableView(rawValue: section) else { return ""}
        return key.description
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView,
              let headerText = header.textLabel  else { return }
        headerText.textColor = .white
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        header.clipsToBounds = true
        header.layer.cornerRadius = 10
        blurEffectView.frame = header.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        header.backgroundView = blurEffectView
    }
}

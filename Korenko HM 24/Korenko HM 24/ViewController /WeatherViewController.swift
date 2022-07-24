//
//  ViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 19.06.22.
//

import UIKit
import RealmSwift
import CoreLocation

enum SectionTableView: Int {
    case current = 0
    case hourly = 1
    case daily = 2
    
    var description: String {
        switch self {
        case .current:
            return "CURRENT FORECAST".localize
        case .hourly:
            return "HOURLY FORECAST".localize
        case .daily:
            return "7-DAY FORECAST".localize
        }
    }
}

class WeatherViewController: UIViewController {

    static let key = "WeatherViewController"
    
    private var apiProvider: RestAPIProviderProtocol!
    private var realmProvider: RealmServiceProtocol!
// MARK: IBOutlet
    
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var mainTableView: UITableView!
    let myRefreshControll: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(rehresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var coreManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    
    var latitude: Double?
    var longitude: Double?
    var cityName = "moscow"
    var weatherData: WeatherData?
    var weatherDataHourly: [Hourly]?
    var weatherDataCurrent: Current?
    var weatherDataDaily: [Daily]?
    var measurement = UnitsOfMeasurement.metric
    var timeFormat24 = Bool()
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationIdentifierSnow = "WeatherNotification"
    let notificationIdentifierRain = "WeatherNotification"
    let notificationIdentifierThunder = "WeatherNotification"
    let keyForUserDefaults = "1"
    let lastCityName = "city"
    let localize = NSLocale.preferredLanguages.first
    var badWeather = BadWeather()
    var items: Results<SettingRealm>!
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerView.hidesWhenStopped = true
        spinnerView.startAnimating()
        
        mainTableView.refreshControl = myRefreshControll
        
        apiProvider = AlamofireProvider()
        realmProvider = RealmService()
        items = realmProvider.reloadListSetting()
        
        mainTableView.dataSource = self
        mainTableView.delegate = self
        coreManager.delegate = self
        
        mainTableView.register(UINib(nibName: CurrentWeatherCell.key, bundle: nil), forCellReuseIdentifier: CurrentWeatherCell.key)
        mainTableView.register(UINib(nibName: HourlyWeatherCell.key, bundle: nil), forCellReuseIdentifier: HourlyWeatherCell.key)
        mainTableView.register(UINib(nibName: DailyWeatherForTableCell.key, bundle: nil), forCellReuseIdentifier: DailyWeatherForTableCell.key)
       
    
        if !UserDefaults.standard.bool(forKey: keyForUserDefaults) {
            if let city = UserDefaults.standard.string(forKey: lastCityName), !city.isEmpty {
                getCoordinatesByName(name: cityName)
            } else {
                getCoordinatesByName(name: cityName)
            }
        }
        
        if let item = items.first {
            badWeather.rawValue = item.weather
            if item.isMetricUnits {
                measurement = UnitsOfMeasurement.metric
            } else {
                measurement = UnitsOfMeasurement.imperial
            }
            if item.isTimeFormat24 {
                timeFormat24 = item.isTimeFormat24
            } else {
                timeFormat24 = item.isTimeFormat24
            }
        } else {
            realmProvider.addSettingRealm(isTimeFormat24: true)
            realmProvider.addSettingRealm(isMetricUnits: true)
            realmProvider.addSettingRealm(weather: 0)
        }
        
        guard let item = items.first else { return }
        
        notificationToken = item.observe{ [weak self] change in
            guard let self = self else { return }
            switch change {
            case .change(_, _):
                guard let changeWeather = self.realmProvider.reloadListSetting().first else { return }
                self.badWeather.rawValue = changeWeather.weather
                if changeWeather.isMetricUnits {
                    self.measurement = UnitsOfMeasurement.metric
                } else {
                    self.measurement = UnitsOfMeasurement.imperial
                }
                if changeWeather.isTimeFormat24 {
                    self.timeFormat24 = changeWeather.isTimeFormat24
                } else {
                    self.timeFormat24 = changeWeather.isTimeFormat24
                }
                guard let lat = self.latitude, let lon = self.longitude else { return }
                self.refreshController(lat: lat, lon: lon)
            default:
                break
            }
        }
        
    }

    deinit {
        guard let token = notificationToken else { return }
        token.invalidate()
    }
    
// MARK: Actions
    
    @IBAction func searchButton(_ sender: Any) {
        choseCityAlertController()
    }
    
    @IBAction func locationButton(_ sender: Any) {
        if coreManager.authorizationStatus == .notDetermined {
            coreManager.requestWhenInUseAuthorization()
        } else if coreManager.authorizationStatus == .authorizedAlways || coreManager.authorizationStatus == .authorizedWhenInUse {
            coreManager.requestLocation()
        }
        
        
    }
    
// MARK: METODS for refreshController
    
    @objc private func rehresh(sender: UIRefreshControl){
        guard let lat = latitude, let lon = longitude else { return }
        refreshController(lat: lat, lon: lon)
        sender.endRefreshing()
    }
    
    func refreshController(lat: Double, lon: Double) {
        apiProvider.getWeatherForCityCoordinates(lat: lat, lon: lon, measurement: measurement.description) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                guard let weather = value.current.weather.first else { return }
                self.longitude = value.lon
                self.latitude = value.lat
                self.weatherData = value
                self.weatherDataDaily = Array(value.daily.dropFirst())
                DispatchQueue.global().async {
                    self.getNotificationForWeather(weatherData: value.hourly, badWeather: self.badWeather)
                    let imageBackground = self.getImageForWeatherView(weather: weather.id)
                    DispatchQueue.main.async {
                        self.regionLabel.text = value.timezone
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
    
// MARK: METODS FOR LOCATION BUTTON
    func getWeatherForLocationButton(coordinate: CLLocation) {
        apiProvider.getWeatherForCityCoordinates(lat: coordinate.coordinate.latitude, lon: coordinate.coordinate.longitude, measurement: measurement.description) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                guard let weather = value.current.weather.first else { return }
                UserDefaults.standard.set(true, forKey: self.keyForUserDefaults)
                self.longitude = value.lon
                self.latitude = value.lat
                self.weatherData = value
                self.weatherDataDaily = Array(value.daily.dropFirst())
                self.realmProvider.addObjectInRealm(weather: value, isLocation: true)
                DispatchQueue.global().async {
                    self.getNotificationForWeather(weatherData: value.hourly, badWeather: self.badWeather)
                    let imageBackground = self.getImageForWeatherView(weather: weather.id)
                    guard let imageSearch = UIImage(systemName: "magnifyingglass")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                          let imageLocation = UIImage(systemName: "location.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal) else { return }
                    DispatchQueue.main.async {
                        self.searchButton.setImage(imageSearch, for: .normal)
                        self.locationButton.setImage(imageLocation, for: .normal)
                        self.regionLabel.text = value.timezone
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
    
// MARK: METODS FOR SEARCH BUTTON
    
    fileprivate func getCoordinatesByName(name: String) {
        apiProvider.getCoordinateByName(name: name) { [weak self] result in
                guard let self = self,
                      let locale = self.localize else { return }
                switch result {
                case .success(let value):
                    if let city = value.first {
                        guard let localNameCity = city.localNames[locale] else { return }
                        self.getWeatherByCoordinates(city: city, nameCity: localNameCity)
                    } else {
                        self.errorAlertController(error: MaccoError.invalidNameCity.localizedDescription)
                        self.spinnerView.stopAnimating()
                    }
                case .failure(let error):
                    self.errorAlertController(error: error.localizedDescription)
                    self.spinnerView.stopAnimating()
                }
            }
        }
        
    private func getWeatherByCoordinates(city: Geocoding, nameCity: String) {
        apiProvider.getWeatherForCityCoordinates(lat: city.lat, lon: city.lon, measurement: measurement.description) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                guard let weather = value.current.weather.first else { return }
                UserDefaults.standard.set(false, forKey: self.keyForUserDefaults)
                UserDefaults.standard.set(nameCity, forKey: self.lastCityName)
                self.longitude = value.lon
                self.latitude = value.lat
                self.weatherData = value
                self.weatherDataDaily = Array(value.daily.dropFirst())
                DispatchQueue.global(qos: .userInteractive).async {
                    self.getNotificationForWeather(weatherData: value.hourly, badWeather: self.badWeather)
                    let imageBackground = self.getImageForWeatherView(weather: weather.id)
                    guard let imageSearch = UIImage(systemName: "magnifyingglass")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal),
                          let imageLocation = UIImage(systemName: "location")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
                    DispatchQueue.main.async {
                        self.locationButton.setImage(imageLocation, for: .normal)
                        self.searchButton.setImage(imageSearch, for: .normal)
                        self.view.backgroundColor = imageBackground
                        self.mainTableView.reloadData()
                        self.spinnerView.stopAnimating()
                        self.regionLabel.text = nameCity
                    }
                }
                self.realmProvider.addObjectInRealm(weather: value, isLocation: true)
            case .failure(let error):
                self.errorAlertController(error: error.localizedDescription)
                self.spinnerView.stopAnimating()
            }
        }
    }
    
// MARK: METODS
    
   // состояние кнопок
    
    func changeButtonCondition(isLocation: Bool) {
        if isLocation {
            guard let imageLocation = UIImage(systemName: "location.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal),
                  let imageSearch = UIImage(systemName: "magnifyingglass")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
            locationButton.setImage(imageLocation, for: .normal)
            searchButton.setImage(imageSearch, for: .normal)
        } else {
            guard let imageSearch = UIImage(systemName: "magnifyingglass")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal),
                  let imageLocation = UIImage(systemName: "location")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
            searchButton.setImage(imageSearch, for: .normal)
            locationButton.setImage(imageLocation, for: .normal)
        }
    }
    
    // Chose City alertController
    
    func choseCityAlertController() {
        let alertController = UIAlertController(title: "Chose city".localize, message: "Please, enter the name of the city".localize, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name city".localize
            textField.delegate = self
        }
        let okButton = UIAlertAction(title: "Enter".localize, style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first,
                  let text = textField.text,
                  let self = self else { return }
            self.spinnerView.hidesWhenStopped = true
            self.spinnerView.startAnimating()
            self.getCoordinatesByName(name: text)
        }
        let cancelButton = UIAlertAction(title: "Cancel".localize, style: .destructive)
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    
    func errorAlertController(error: String) {
        let alrtController = UIAlertController(title: "Error".localize, message: error, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Repeat".localize, style: .cancel) { _ in
            self.spinnerView.stopAnimating()
        }
        alrtController.addAction(okButton)
        present(alrtController, animated: true)
    }
    
    
    // метод проверки почасовой погоды
    func getNotificationForWeather(weatherData: [Hourly], badWeather: BadWeather) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [notificationIdentifierSnow, notificationIdentifierRain, notificationIdentifierThunder])
        for weather in weatherData.dropFirst() {
            var counterSnow = 0
            var counterRain = 0
            var counterThunder = 0
            guard let weatherId = weather.weather.first else { return }
            
            if badWeather.contains(.thunder), counterThunder == 0, WeatherId.thunder.badWeatherRange.contains(weatherId.id)  {
                addNotification(weather: weatherId.main.rawValue, time: weather.dt.getTimeForNotification, notificationIdentifier: notificationIdentifierThunder)
                counterThunder += 1
            } else if badWeather.contains(.rain), counterRain == 0, WeatherId.rain.badWeatherRange.contains(weatherId.id) {
                addNotification(weather: weatherId.main.rawValue, time: weather.dt.getTimeForNotification, notificationIdentifier: notificationIdentifierRain)
                counterRain += 1
            } else if badWeather.contains(.snow), counterSnow == 0, WeatherId.snow.badWeatherRange.contains(weatherId.id) {
                addNotification(weather: weatherId.main.rawValue, time: weather.dt.getTimeForNotification, notificationIdentifier: notificationIdentifierSnow)
                counterSnow += 1
            }
        }
    }
    
    // метод добавления уведомления
    func addNotification(weather: String, time: DateComponents, notificationIdentifier: String ) {
        let content = UNMutableNotificationContent()
        content.title = "Warning".localize
        content.body = "\(weather) \("will be in 30 minute!".localize)"
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
            currentCell.changeParams(isMetric: measurement, isTimeFormat24: timeFormat24)
            return currentCell
        case 1:
            hourlyCell.weatherHourly = weather.hourly
            hourlyCell.timeFormat24 = timeFormat24
            return hourlyCell
        case 2:
            dailyCell.reloadWeatherData(weatherData: weatherDaily[indexPath.row])
            dailyCell.changeMetricTemperature(isMetric: measurement)
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


extension WeatherViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if coreManager.authorizationStatus == .denied {
            locationButton.isEnabled = false
        } else if coreManager.authorizationStatus == .authorizedAlways || coreManager.authorizationStatus == .authorizedWhenInUse {
            
            if UserDefaults.standard.bool(forKey: keyForUserDefaults) {
                coreManager.requestLocation()
            guard let imageLocation = UIImage(systemName: "location.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal),
                  let imageSearch = UIImage(systemName: "magnifyingglass")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
            locationButton.setImage(imageLocation, for: .normal)
            searchButton.setImage(imageSearch, for: .normal)
            } else {
                guard let imageLocation = UIImage(systemName: "location.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                      let imageSearch = UIImage(systemName: "magnifyingglass")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal) else { return }
                locationButton.setImage(imageLocation, for: .normal)
                searchButton.setImage(imageSearch, for: .normal)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else { return }
        getWeatherForLocationButton(coordinate: userLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorAlertController(error: error.localizedDescription)
    }
    
    
}

extension WeatherViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: string)) || CharacterSet(charactersIn: "-'. ,").isSuperset(of:  CharacterSet(charactersIn: string)) else { return false }
        return true
    }
}

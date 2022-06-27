//
//  ViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 19.06.22.
//

import UIKit

class WeatherViewController: UIViewController {

    private var apiProvider: RestAPIProviderProtocol!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    
    @IBOutlet weak var collectionTable: UICollectionView!
    
    
    
    
    
    
    var weatherData: WeatherData?
    var nameCity = String()
    var measurement = UnitsOfMeasurement.metric
    var image = UIImage()
    var hourly: [Hourly]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionTable.delegate = self
        collectionTable.dataSource = self
        collectionTable.register(UINib(nibName: myCollectionCell.key, bundle: nil), forCellWithReuseIdentifier: myCollectionCell.key)
        
        apiProvider = AlamofireProvider()
      
        
    }

    @IBAction func choseCity(_ sender: Any) {
        alertControllerForChoseCity()
        
        
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
                self.hourly = value.hourly
                print(value.current)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Метод для alertController
    
    func alertControllerForChoseCity() {
        let choseCityAlert = UIAlertController(title: "Chose city", message: "Enter the name of the city", preferredStyle: .alert)
        choseCityAlert.addTextField { textField in
            textField.placeholder = "Name city"
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        let setPasswordButton = UIAlertAction(title: "OK", style: .cancel){ [weak self] _ in
            guard let textField = choseCityAlert.textFields?[0],
                  let text = textField.text,
                  let self = self else { return }
            let textWithoutWhitespace = text.trimmingCharacters(in: .whitespaces)
            self.nameCity = textWithoutWhitespace
            DispatchQueue.global().async { [weak self]  in
                guard let self = self else { return }
                self.getCoordinatesByName(name: self.nameCity)
                DispatchQueue.main.async {
                    self.changeMainView()
                    self.collectionTable.reloadData()
                }
            }
        }
            
            choseCityAlert.addAction(setPasswordButton)
            choseCityAlert.addAction(cancelButton)
            present(choseCityAlert, animated: true)
    }
    
    
    func changeMainView() {
        guard let weatherData = weatherData,
              let weatherdescription = weatherData.current.weather.first else { return }
        let API = "https://openweathermap.org/img/wn/\(weatherdescription.icon)@2x.png"
        getIconImage(API: API)

        tempLabel.text = String(weatherData.current.temp)
        feelsLikeLabel.text = "Feels like \(weatherData.current.feelsLike)"
        weatherDescriptionLabel.text = weatherdescription.weatherDescription.description
        imageView.image = image
        
    }
    
    func getIconImage(API: String) {
        let api = API
        guard let apiURL = URL(string: api) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: apiURL) { (data, response, error) in
            guard let data = data, let icon = UIImage(data: data), error == nil else { return }
            self.image = icon
        }
        task.resume()
    }
    
    func convertUnixType(dt: Double) -> String {
        let date = Date(timeIntervalSince1970: dt)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    
    
    
}

//extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        UITableViewCell()
//    }
//
//
//}


extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let hourly = hourly else { return 0 }
        return hourly.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myCollectionCell.key, for: indexPath) as? myCollectionCell else { return UICollectionViewCell() }
        
        guard let weatherHourly = hourly,
              let weather = weatherHourly[indexPath.row].weather.first else { return UICollectionViewCell() }
      
        var hourly = weatherHourly[indexPath.row]
        
        cell.timeLabel.text = convertUnixType(dt: Double(hourly.dt))
        cell.tempLabel.text = String(hourly.temp)
        cell.layer.cornerRadius = 20 
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
}

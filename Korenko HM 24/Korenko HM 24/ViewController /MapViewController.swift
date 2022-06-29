//
//  MapViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 26.06.22.
//

import UIKit
import GoogleMaps
import RealmSwift

class MapViewController: UIViewController {
    static let key = "MapViewController"
    private var apiProvider: RestAPIProviderProtocol!
    var measurement = UnitsOfMeasurement.metric
    let realm = try! Realm()
    
// MARK: IBOutlet
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiProvider = AlamofireProvider()
        mainView.layer.cornerRadius = 15
        mainView.isHidden = true
        
        let camera = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.579, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        mainView.isHidden = true
        view.addSubview(mapView)
        view.addSubview(mainView)
        
        
    }
    
    
// кнопка закрытия mainView
    @IBAction func closeButton(_ sender: Any) {
        mainView.isHidden = true
    }
    
    
    
// MARK: Metods
    
    // получение данных для погоды
    func getWeatherByCoordinates(lat: Double, lon: Double, measurement: String) {
        apiProvider.getWeatherForCityCoordinates(lat: lat, lon: lon, measurement: measurement) { result in
            switch result {
            case .success(let value):
                self.reloadMainView(weather: value.current)
                addObjectInRealm(weather: value, realm: self.realm)
            case .failure(let error):
                self.errorAlertController(error: error.localizedDescription)
            }
        }
    }
    
    // запрос для получения картинки

    
    
    // errror контролер для выведения ошибки в норм виде
    func errorAlertController(error: String) {
        let alrtController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Repeat", style: .cancel){ [weak self] _ in
            guard let self = self else { return }
            self.mainView.isHidden = true
        }
        alrtController.addAction(okButton)
        present(alrtController, animated: true)
    }
    
    
    // обновление mainView
    func reloadMainView(weather: Current) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let weatherDescription = weather.weather.first else { return }
            self.temperatureLabel.text = "\(String(Int(weather.temp))) C"
            self.feelsLikeLabel.text = "Feels like \(Int(weather.feelsLike)) C"
            self.weatherDescriptionLabel.text = weatherDescription.weatherDescription.description
            self.imageView.image = getIconImage(iconId: weatherDescription.icon)
            self.mainView.isHidden = false
        }
    }
    
}


// extention для отображения mainView
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.getWeatherByCoordinates(lat: coordinate.latitude, lon: coordinate.longitude, measurement: self.measurement.description)
        }
    }
}

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

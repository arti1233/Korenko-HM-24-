//
//  MapViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 26.06.22.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    private var apiProvider: RestAPIProviderProtocol!
    var wetherData: Current?
    var measurement = UnitsOfMeasurement.metric
    var image = UIImage()
    
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
    
    
    
    @IBAction func closeButton(_ sender: Any) {
        mainView.isHidden = true
    }
    
    
    
// MARK: Metods
    
    // получение данных для погоды
    func getWeatherByCoordinates(lat: Double, lon: Double, measurement: String) {
        apiProvider.getWeatherForCityCoordinates(lat: lat, lon: lon, measurement: measurement) { result in
            switch result {
            case .success(let value):
                self.wetherData = value.current
                print(value.current)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // запрос для получения картинки
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
    
}


// extention для отображения mainView
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.getWeatherByCoordinates(lat: coordinate.latitude, lon: coordinate.longitude, measurement: self.measurement.description)
            guard let weather = self.wetherData,
                  let weatherDescription = weather.weather.first else { return }
            let description = weatherDescription.weatherDescription.description
            let API = "https://openweathermap.org/img/wn/\(weatherDescription.icon)@2x.png"
            self.getIconImage(API: API)
        
            
            DispatchQueue.main.async {
                self.temperatureLabel.text = String(weather.temp)
                self.feelsLikeLabel.text = "Feels like \(weather.feelsLike)"
                self.weatherDescriptionLabel.text = description
                self.imageView.image = self.image
                self.mainView.isHidden = false
                
            }
        }
    }
}

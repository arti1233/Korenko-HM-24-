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
    var image: UIImage?
    
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
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let camera = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.579, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        mainView.isHidden = true
        view.addSubview(mapView)
        view.addSubview(mainView)
        
        
    }

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
    
    @IBAction func closeButton(_ sender: Any) {
        mainView.isHidden = true
    }
    
    func getIconImage(API: String) {
        let api = API
        guard let apiURL = URL(string: api) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: apiURL) { (data, response, error) in
            guard let data = data, let icon = UIImage(data: data), error == nil else { return }
            DispatchQueue.global().async {
                self.image = icon
            }
        }
        task.resume()
    }
    
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        DispatchQueue.global().async {
            self.getWeatherByCoordinates(lat: coordinate.latitude, lon: coordinate.longitude, measurement: self.measurement.description)
            guard let weather = self.wetherData,
                  let weatherDescription = weather.weather.first else { return }
            let description = weatherDescription.weatherDescription.description
            let temp = weather.temp
            let fellsLike = weather.feelsLike
            let API = "https://openweathermap.org/img/wn/\(weatherDescription.icon)@2x.png"
            self.getIconImage(API: API)
        
            
            DispatchQueue.main.async {
                self.temperatureLabel.text = String(temp)
                self.feelsLikeLabel.text = "Feels like \(fellsLike)"
                self.weatherDescriptionLabel.text = description
                self.imageView.image = self.image
                self.mainView.isHidden = false
                
            }
        }
    }
}

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
    var weatherCurrent: Current?
    
    var mapView = GMSMapView()
    var camera = GMSCameraPosition()

    override func viewDidLoad() {
        super.viewDidLoad()
        apiProvider = AlamofireProvider()

        camera = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.579, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        view.addSubview(mapView)
    
        
        
        
        
        
    }
    
    
// MARK: Metods
    
    // errror контролер для выведения ошибки в норм виде
    func errorAlertController(error: String) {
        let alrtController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Repeat", style: .cancel)
        
        alrtController.addAction(okButton)
        present(alrtController, animated: true)
    }
    
    func createMarker(map: GMSMapView, coordinate: CLLocationCoordinate2D){
        map.clear()
        let marker = GMSMarker()
        marker.position = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.map = map
        map.selectedMarker = marker
    }

}


// extention для отображения mainView
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        apiProvider.getWeatherForCityCoordinates(lat: coordinate.latitude, lon: coordinate.longitude, measurement: measurement.description) { result in
            switch result {
            case .success(let value):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.addObjectInRealm(weather: value, metod: "Map")
                    self.weatherCurrent = value.current
                    self.createMarker(map: self.mapView , coordinate: coordinate)
                }
            case .failure(let error):
                self.errorAlertController(error: error.localizedDescription)
            }
        }
    
    }
    
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let view = Bundle.main.loadNibNamed(InfoWindow.key, owner: self)?[0] as? InfoWindow else { return UIView()}
       
        if let weather = weatherCurrent {
            view.reloadMainView(weather: weather)
        }
        return view
    }
    
}


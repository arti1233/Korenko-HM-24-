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
    private var realmProvider: RealmServiceProtocol!
    var measurement = UnitsOfMeasurement.metric
    var weatherCurrent: Current?
    
    let realm = try! Realm()
    
    var mapView = GMSMapView()
    var camera = GMSCameraPosition()

    override func viewDidLoad() {
        super.viewDidLoad()
        apiProvider = AlamofireProvider()
        realmProvider = RealmService()

        camera = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.579, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        view.addSubview(mapView)

        print(realm.configuration.fileURL)
    }
    
    
// MARK: Metods
    
    // errror контролер для выведения ошибки в норм виде
    func errorAlertController(error: String) {
        let alrtController = UIAlertController(title: "Error".localize, message: error, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Repeat".localize, style: .cancel)
        
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
        
        apiProvider.getWeatherForCityCoordinates(lat: coordinate.latitude, lon: coordinate.longitude, measurement: measurement.description) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.realmProvider.addObjectInRealm(weather: value, isLocation: false)
                self.weatherCurrent = value.current
                self.createMarker(map: self.mapView , coordinate: coordinate)
            case .failure(let error):
                self.errorAlertController(error: error.localizedDescription)
            }
        }
    
    }
    
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let view = Bundle.main.loadNibNamed(InfoWindow.key, owner: self)?.first as? InfoWindow else { return UIView()}
       
        if let weather = weatherCurrent {
            view.reloadMainView(weather: weather)
        }
        return view
    }
    
}



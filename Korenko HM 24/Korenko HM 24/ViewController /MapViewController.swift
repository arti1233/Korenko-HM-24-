//
//  MapViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 26.06.22.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    @IBOutlet weak var viewForMaps: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let camera = GMSCameraPosition.camera(withLatitude: 54.029, longitude: 27.579, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        
        view.addSubview(mapView)
        
    }


}

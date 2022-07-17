//
//  RequestListRealmData.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import Foundation
import RealmSwift
import UIKit


class RequestListRealmData: Object {
    @objc dynamic var lat: Double = 0
    @objc dynamic var lon: Double = 0
    @objc dynamic var time = Date()
    @objc dynamic var isLocation: Bool = false
    @objc dynamic var weather: WeatherDataRealm?
}

class WeatherDataRealm: Object {
    @objc dynamic var temp: Double = 0
    @objc dynamic var feelsLike: Double = 0
    @objc dynamic var descriptionWeather: String = ""
    @objc dynamic var icon: String = ""
}

class RealmService: RealmServiceProtocol {
    
    let realm = try! Realm()
    
    func reloadListRequest() -> Results<RequestListRealmData> {
        return realm.objects(RequestListRealmData.self)
    }
    
   
    func addObjectInRealm(weather: WeatherData, isLocation: Bool) {
        guard let weatherDiscription = weather.current.weather.first else { return }
        let weatherObject = WeatherDataRealm()
        weatherObject.temp = weather.current.temp
        weatherObject.feelsLike = weather.current.feelsLike
        weatherObject.icon = weatherDiscription.icon
        weatherObject.descriptionWeather = weatherDiscription.weatherDescription
        let object = RequestListRealmData()
        object.lon = weather.lon
        object.lat = weather.lat
        object.time = Date()
        object.weather = weatherObject
        object.isLocation = isLocation
    
        try! realm.write{
            realm.add(weatherObject)
            realm.add(object)
        }
    }
    
    
    
    
    
    
    
}

protocol RealmServiceProtocol {
    
    func addObjectInRealm(weather: WeatherData, isLocation: Bool) 
    
    func reloadListRequest() -> Results<RequestListRealmData>
    
}

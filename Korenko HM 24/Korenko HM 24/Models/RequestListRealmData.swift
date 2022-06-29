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
    @objc dynamic var time = NSDate()
    @objc dynamic var weather: WeatherDataRealm?
}

class WeatherDataRealm: Object {
    @objc dynamic var temp: Double = 0
    @objc dynamic var feelsLike: Double = 0
    @objc dynamic var descriptionWeather: String = ""
    @objc dynamic var icon: String = ""
}


func addObjectInRealm(weather: WeatherData, realm: Realm) {
    
    guard let weatherDiscription = weather.current.weather.first else { return }
    
    let weatherObject = WeatherDataRealm()
    weatherObject.temp = weather.current.temp
    weatherObject.feelsLike = weather.current.feelsLike
    weatherObject.icon = weatherDiscription.icon
    weatherObject.descriptionWeather = weatherDiscription.weatherDescription.description
    let object = RequestListRealmData()
    object.lon = weather.lon
    object.lat = weather.lat
    object.time = NSDate()
    object.weather = weatherObject
    
    try! realm.write{
        realm.add(weatherObject)
        realm.add(object)
    }
    
    
}

func getTime(time: NSDate) -> String {
    let time = time
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    formatter.timeZone = TimeZone(secondsFromGMT: 3)            // указатель временной зоны относительно гринвича
    let formatteddate = formatter.string(from: time as Date)
    return formatteddate
}


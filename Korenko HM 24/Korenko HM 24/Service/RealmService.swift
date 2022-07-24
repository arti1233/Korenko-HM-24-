//
//  RequestListRealmData.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import Foundation
import RealmSwift
import UIKit
import CloudKit


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

class SettingRealm: Object {
    
    static let id: Int = 0
    
    @objc dynamic var id: Int = SettingRealm.id
    @objc dynamic var weather: Int = 0
    @objc dynamic var isMetricUnits: Bool = true
    @objc dynamic var isTimeFormat24: Bool = true
        
    override class func primaryKey() -> String? {
        return "id"
    }
}

class RealmService: RealmServiceProtocol {
    
    let realm = try! Realm()
    var settingList = SettingRealm()
    
    
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
    
    func addSettingRealm(weather: Int) {
        try! realm.write{
            settingList.weather = weather
            realm.add(settingList, update: .modified)
        }
    }
    
    func addSettingRealm(isMetricUnits: Bool) {
        try! realm.write{
            settingList.isMetricUnits = isMetricUnits
            realm.add(settingList, update: .modified)
        }
    }
    
    func addSettingRealm(isTimeFormat24: Bool) {
        try! realm.write{
            settingList.isTimeFormat24 = isTimeFormat24
            realm.add(settingList, update: .modified)
        }
    }
    
    
    func reloadListSetting() -> Results<SettingRealm> {
        return realm.objects(SettingRealm.self)
    }
    
    func getSettingObject() -> SettingRealm {
        return settingList
    }
    
    
}

protocol RealmServiceProtocol {
    
    func addObjectInRealm(weather: WeatherData, isLocation: Bool) 

    func reloadListRequest() -> Results<RequestListRealmData>
    
    func addSettingRealm(weather: Int)
    
    func addSettingRealm(isMetricUnits: Bool)
    
    func addSettingRealm(isTimeFormat24: Bool)
   
    func reloadListSetting() -> Results<SettingRealm>
    
    func getSettingObject() -> SettingRealm
}

//
//  HourlyWeatherData.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 24.06.22.
//

import Foundation

struct HourlyWeatherData: Codable {
    var dt: Int?
    var temp: Double?
    var feelsLike: Double?
    var pressure: Int?
    var humidity: Int?
    var dewPoint: Double?
    var uvi: Double?
    var clouds: Int?
    var visibility: Int?
    var windSpeed: Double?
    var windDeg: Int?
    var windGust: Double?
    var weather: [WeatherHourly]?
    var pop: Double?
    
    enum CodingKeys: String, CodingKey {
        case dt, temp, pressure, humidity, uvi, clouds, visibility, weather, pop
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
}

struct WeatherHourly: Codable {
    var id: Int?
    var main: String?
    var description: String?
    var icon: String?
}

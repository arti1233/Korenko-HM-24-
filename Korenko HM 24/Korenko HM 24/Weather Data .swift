//
//  Weather Data .swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 19.06.22.
//

import Foundation
import CoreText

struct WeatherData: Codable {
    var coord: Coord?
    var weather: [Weather]?
    var base, name: String?
    var temperature: Main?
    var visibility, dt, timezone, id, cod: Int?
    var wind: Wind?
    var clouds: Clouds?
    var sys: Sys?
    // изменил main на temperature чтобы было понятней
    enum CodingKeys: String, CodingKey {
        case temperature = "main"
        case coord, weather, base, name, visibility, dt, timezone, id, cod, wind, clouds, sys
    }
}

struct Coord: Codable {
    var longitude: Float?
    var latitude: Float?
    // сделал полные названия
    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

struct Weather: Codable {
    var id: Int?
    var main: String?
    var description: String?
    var icon: String?
}

struct Main: Codable {
    var temp: Float?
    var feelsLike: Float?
    var tempMin: Float?
    var tempMax: Float?
    var pressure: Float?
    var humidity: Float?
    var seaLevel: Float?
    var grndLevel: Float?
    // избавился от нижний подчеркиваний
    enum CodingKeys: String, CodingKey {
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case temp, pressure, humidity
    }
}

struct Wind: Codable {
    var speed: Float?
    var deg: Float?
    var gust: Float?
}

struct Clouds: Codable {
    var all: Int?
}

struct Sys: Codable {
    var type: Int?
    var id: Int?
    var country: String?
    var sunrise: Int?
    var sunset: Int?
}

// зделал через enum переключение между единицами измерения
enum UnitsOfMeasurement {
    case standart
    case metric
    case imperial
    
    var description: String {
        switch self {
        case .standart:
            return ""
        case .metric:
            return "&units=metric"
        case .imperial:
            return "&units=imperial"
        }
    }
}

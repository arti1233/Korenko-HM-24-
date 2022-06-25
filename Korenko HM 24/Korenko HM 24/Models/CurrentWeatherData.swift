//
//  CurrentWeatherData.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 24.06.22.
//

import Foundation


enum UnitsOfMeasurement {
    case metric
    case imperial
    
    var description: String {
        switch self {
        case .metric:
            return "metric"
        case .imperial:
            return "imperial"
        }
    }
}

// MARK: - Weather
struct WeatherData: Codable {
    let lat, lon: Double
    let timezone: String
    let timezoneOffset: Int
    let current: CurrentWeaterData
    let hourly: [HourlyWeaterData]
    let daily: [DailyWeaterData]

    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case timezoneOffset = "timezone_offset"
        case current, hourly, daily
    }
}

// MARK: - Current
struct CurrentWeaterData: Codable {
    let dt: Int
    let sunrise, sunset: Int?
    let temp, feelsLike: Double
    let pressure, humidity: Int
    let dewPoint, uvi: Double
    let clouds, visibility: Int
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double
    let weather: [WeatherElement]
    let pop: Double?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case uvi, clouds, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather, pop
    }
}


struct WeatherElement: Codable {
    let id: Int
    let main: Main
    let weatherDescription: Description
    let icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

enum Main: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}

enum Description: String, Codable {
    case brokenClouds = "broken clouds"
    case clearSky = "clear sky"
    case fewClouds = "few clouds"
    case lightRain = "light rain"
    case scatteredClouds = "scattered clouds"
}

struct FeelsLike: Codable {
    let day, night, eve, morn: Double
}

struct Temp: Codable {
    let day, min, max, night: Double
    let eve, morn: Double
}

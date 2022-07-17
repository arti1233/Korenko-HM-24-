//
//  AlamofierProvider.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 24.06.22.
//

import Foundation
import Alamofire
import UIKit

protocol RestAPIProviderProtocol {
    
    func getCoordinateByName(name: String, completion: @escaping (Result<[Geocoding], Error>) -> Void)
    func getWeatherForCityCoordinates(lat: Double, lon: Double, measurement: String, completion: @escaping (Result<WeatherData, Error>) -> Void)
}



class AlamofireProvider: RestAPIProviderProtocol {
    
    func getlanguage() -> String {
        guard let locale = NSLocale.preferredLanguages.first else { return "en"}
        return locale
    }
    
    func getWeatherForCityCoordinates(lat: Double, lon: Double, measurement: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
    
        let params = addParams(queryItems: ["lat": lat.description, "lon": lon.description, "exclude": "minutely,alerts", "units": measurement, "lang": getlanguage()])
        
        AF.request(Constants.weatherURL, method: .get, parameters: params).responseDecodable(of: WeatherData.self) { response in
            switch response.result {
            case .success(let result):
                return completion(.success(result))
            case .failure:
                return completion(.failure(MaccoError.invalidCoordinate))
            }
        }
    }
    
    func getCoordinateByName(name: String, completion: @escaping (Result<[Geocoding], Error>) -> Void) {
        let params = addParams(queryItems: ["q": name, "lang": getlanguage()])
        
        AF.request(Constants.getCodingURL, method: .get, parameters: params).responseDecodable(of: [Geocoding].self) { response in
            switch response.result {
            case .success(let result):
                return completion(.success(result))
            case .failure:
                return completion(.failure(MaccoError.invalidNameCity))
            }
        }
    }
}

private func addParams(queryItems: [String: String]) -> [String: String] {
    guard let key = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else { return [:] }
    var params: [String: String] = [:]
    params = queryItems
    params["appid"] = key
    return params
}

enum MaccoError: LocalizedError {
    
    case invalidNameCity
    case invalidCoordinate
    
    var errorDescription: String? {
        switch self {
        case .invalidNameCity:
            return NSLocalizedString("Invalid city name", comment: "")
        case .invalidCoordinate:
            return NSLocalizedString("Error getting weather", comment: "")
        }
    }
    
}

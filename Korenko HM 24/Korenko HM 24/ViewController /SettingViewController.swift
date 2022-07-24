//
//  ListViewController.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import Foundation
import RealmSwift
import UIKit

enum SettingSection: Int, CaseIterable {
    case weather = 0
    case measurement = 1
    case timeFormat = 2
    
    var description: String {
        switch self {
        case .weather:
            return "Weather Notifications".localize
        case .measurement:
            return "Units of measurement".localize
        case .timeFormat:
            return "Time format".localize
        }
    }
}

enum UnfavorableWeather: CaseIterable {
    case snow
    case rain
    case thunder
    
    var description: String {
        switch self {
        case .snow:
            return "Snow".localize
        case .rain:
            return "Rain".localize
        case .thunder:
            return "Thunder".localize
        }
    }
    
    var badWeather: BadWeather {
        switch self {
        case .snow:
            return .snow
        case .rain:
            return .rain
        case .thunder:
            return .thunder
        }
    }
}

enum TimeFormat: CaseIterable {
    case timeFormat24
    case timeFormat12
    
    var description: String {
        switch self {
        case .timeFormat24:
            return "Time format 24".localize
        case .timeFormat12:
            return "Time format 12".localize
        }
    }
}

enum WeatherId: CaseIterable {
    case rain
    case snow
    case thunder
    
    var badWeatherRange: ClosedRange<Int> {
        switch self {
        case .rain:
            return 500...531
        case .snow:
            return 600...622
        case .thunder:
            return 200...232
        }
    }
}

struct BadWeather: OptionSet {
    var rawValue: Int
    
    static let snow = BadWeather(rawValue: 1 << 0)
    static let rain = BadWeather(rawValue: 1 << 1)
    static let thunder = BadWeather(rawValue: 1 << 2)
}

class SettingViewController: UIViewController {
    static let key = "SetingViewController"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingLabel: UILabel!
    var items: Results<SettingRealm>!
    var badWeather = BadWeather()
    var isTimeFormat = Bool()
    var isMeasurment = Bool()
    private var realmProvider: RealmServiceProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realmProvider = RealmService()
        items = realmProvider.reloadListSetting()
        
        if let item = items.first {
            badWeather.rawValue = item.weather
            isMeasurment = item.isMetricUnits
            isTimeFormat = item.isTimeFormat24
        } else {
            badWeather.rawValue = 0
            isMeasurment = true
            isTimeFormat = true
        }

        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: SettingCell.key, bundle: nil), forCellReuseIdentifier: SettingCell.key)
        tableView.register(UINib(nibName: MeasurmentSettingCell.key, bundle: nil), forCellReuseIdentifier: MeasurmentSettingCell.key)
        
        tableView.allowsMultipleSelection = true
        
        settingLabel.text = "Settings".localize
    }
    
    func selectionForCellTableView (indexPath: IndexPath, isSelected: Bool){
        if let cell = tableView.cellForRow(at: indexPath) as? SettingCell {
            cell.setSelectedAttribute(isSelected: isSelected)
        } else if let cell = tableView.cellForRow(at: indexPath) as? MeasurmentSettingCell {
            cell.setSelectedAttribute(isSelected: isSelected)
        }
    }
    
    
    @IBAction func showListRequest(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ListStoryboard", bundle: nil)
        if let VC = storyboard.instantiateViewController(withIdentifier: ListViewController.key) as? ListViewController {
            present(VC, animated: true)
        }
    }
    
    
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        SettingSection.allCases.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let values = SettingSection.allCases[section]
        
        switch values {
        case .weather:
            return UnfavorableWeather.allCases.count
        case .measurement:
            return 1
        case .timeFormat:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.key) as? SettingCell else { return UITableViewCell()}
        guard let cellSetting = tableView.dequeueReusableCell(withIdentifier: MeasurmentSettingCell.key) as?  MeasurmentSettingCell else { return UITableViewCell()}
 
        let values = SettingSection.allCases[indexPath.section]
        let weather1 = UnfavorableWeather.allCases[indexPath.row]
        cellSetting.selectionStyle = .none
        cell.selectionStyle = .none
        switch values {
        case .weather:
            cell.settingLabel.text = weather1.description
            cell.setSelectedAttribute(isSelected: badWeather.contains(weather1.badWeather))
            return cell
        case .measurement:
            cellSetting.settingLabel.text = UnitsOfMeasurement.allCases[indexPath.row].description.localize
            cellSetting.switchSetting.isOn = isMeasurment
            cellSetting.completion = { [weak self] result in
                guard let self = self else { return }
                if result {
                    self.realmProvider.addSettingRealm(isMetricUnits: result)
                } else {
                    self.realmProvider.addSettingRealm(isMetricUnits: result)
                }
            }
            return cellSetting
        case .timeFormat:
            cellSetting.settingLabel.text = TimeFormat.allCases[indexPath.row].description
            cellSetting.switchSetting.isOn = isTimeFormat
            cellSetting.completion = { [weak self] result in
                guard let self = self else { return }
                if result {
                    self.realmProvider.addSettingRealm(isTimeFormat24: result)
                } else {
                    self.realmProvider.addSettingRealm(isTimeFormat24: result)
                }
            }
            return cellSetting
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let values = SettingSection.allCases[indexPath.section]
        let weather = UnfavorableWeather.allCases[indexPath.row]

        switch values {
        case .weather:
            switch weather {
            case .snow:
                selectionForCellTableView(indexPath: indexPath, isSelected: true)
                badWeather.insert(.snow)
            case .rain:
                selectionForCellTableView(indexPath: indexPath, isSelected: true)
                badWeather.insert(.rain)
            case .thunder:
                selectionForCellTableView(indexPath: indexPath, isSelected: true)
                badWeather.insert(.thunder)
            }
        default:
            break
        }
        
        realmProvider.addSettingRealm(weather: badWeather.rawValue)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let values = SettingSection.allCases[indexPath.section]
        let weather = UnfavorableWeather.allCases[indexPath.row]

        switch values {
        case .weather:
            switch weather {
            case .snow:
                selectionForCellTableView(indexPath: indexPath, isSelected: false)
                badWeather.remove(.snow)
            case .rain:
                selectionForCellTableView(indexPath: indexPath, isSelected: false)
                badWeather.remove(.rain)
            case .thunder:
                selectionForCellTableView(indexPath: indexPath, isSelected: false)
                badWeather.remove(.thunder)
            }
        default:
            break
        }

        realmProvider.addSettingRealm(weather: badWeather.rawValue)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let key = SettingSection(rawValue: section) else { return "" }
        return key.description
    }
}

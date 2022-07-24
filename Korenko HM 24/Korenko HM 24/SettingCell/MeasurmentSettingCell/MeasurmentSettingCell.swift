//
//  MeasurmentSettingCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 21.07.22.
//

import UIKit

class MeasurmentSettingCell: UITableViewCell {

    static let key = "MeasurmentSettingCell"
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var switchSetting: UISwitch!
    var isTimeFormat = Bool()
    var isMeasurment = Bool()
    
    var completion: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        switchSetting.addTarget(self, action: #selector(switchChange(target:)), for: .valueChanged)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func setSelectedAttribute(isSelected: Bool) {
        switchSetting.isOn = isSelected
    }
    
    @objc func switchChange(target: UISwitch) {
        guard let completion = completion else { return }
        if target.isOn {
            completion(true)
        } else {
            completion(false)
        }
    }
    
}

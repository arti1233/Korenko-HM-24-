//
//  SettingCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 20.07.22.
//

import UIKit

class SettingCell: UITableViewCell {

    static let key = "SettingCell"
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func setSelectedAttribute(isSelected: Bool) {
        if isSelected {
            guard let imageCircleFill = UIImage(systemName: "circle.fill") else { return }
            iconView.image = imageCircleFill
        } else {
            guard let imageCircle = UIImage(systemName: "circle") else { return }
            iconView.image = imageCircle
        }
    }
  
    
}

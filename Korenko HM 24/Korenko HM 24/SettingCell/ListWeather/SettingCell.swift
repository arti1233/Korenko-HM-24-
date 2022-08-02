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
            iconView.image = UIImage(systemName: "circle.fill")
        } else {
            iconView.image = UIImage(systemName: "circle")
        }
    }
  
    
}

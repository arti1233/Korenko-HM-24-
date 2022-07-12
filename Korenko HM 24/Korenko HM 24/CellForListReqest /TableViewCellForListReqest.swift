//
//  TableViewCellForListReqest.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 29.06.22.
//

import UIKit

class TableViewCellForListReqest: UITableViewCell {

    static let key = "TableViewCellForListReqest"
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    
    
    
    
}

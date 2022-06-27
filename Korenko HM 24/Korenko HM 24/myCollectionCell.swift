//
//  myCollectionCell.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 27.06.22.
//

import UIKit

class myCollectionCell: UICollectionViewCell {

    static var key = "myCollectionCell"
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

}

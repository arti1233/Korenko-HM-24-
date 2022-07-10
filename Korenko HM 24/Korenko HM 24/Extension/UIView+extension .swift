//
//  UIView+extension .swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 10.07.22.
//

import Foundation
import UIKit

@IBDesignable
class RoundView: UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

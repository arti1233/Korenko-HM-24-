//
//  UIView+extension .swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 10.07.22.
//

import Foundation
import UIKit

@IBDesignable
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat{
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}

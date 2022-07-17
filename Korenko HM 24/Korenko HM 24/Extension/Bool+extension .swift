//
//  Bool+extension .swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 17.07.22.
//

import Foundation
import UIKit


extension Bool {
    
    var locationDescription: String {
        if self == true {
            return "current weather"
        } else {
            return "map"
        }
    }
}

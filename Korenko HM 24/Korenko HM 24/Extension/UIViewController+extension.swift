//
//  UIViewController+extension.swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 16.07.22.
//

import Foundation
import UIKit

extension UIViewController {
    
    func localize(key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}

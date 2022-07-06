//
//  Extemsion+ ViewController .swift
//  Korenko HM 24
//
//  Created by Artsiom Korenko on 30.06.22.
//

import Foundation
import UIKit
import RealmSwift

extension Int{
  
    var timeHHmm: String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    var timeMMMd: String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    var getTimeForNotification: DateComponents {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: Double(self - 30 * 60))
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        dateComponents.timeZone = .current
        return dateComponents
    }
    
}

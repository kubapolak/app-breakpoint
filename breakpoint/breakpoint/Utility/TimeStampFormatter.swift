//
//  DateFormatter.swift
//  breakpoint
//
//  Created by Mac on 11/28/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

// Date and time formatting extracted
class TimeStampFormatter {
    
    static let instance = TimeStampFormatter()

    let dateFormatter = DateFormatter()
    
    func formatTime(_ interval: TimeInterval) -> String {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let time = NSDate(timeIntervalSince1970: interval / 1000) as Date
        let currentTime = Date()
        let components = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day], from: time, to: currentTime)
        if components.year! > 0 {
            dateFormatter.dateFormat = "yyyy"
        } else if components.month! > 1 {
            dateFormatter.dateFormat = "MMMM"
        } else if components.month! > 0 {
            dateFormatter.dateFormat = "MMMM dd"
        } else if components.weekOfMonth! > 0 {
            dateFormatter.dateFormat = "dd.MM, HH:mm"
        } else if components.day! > 0 {
            dateFormatter.dateFormat = "EEE, HH:mm"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        let timeCheck = dateFormatter.string(from: time)
        let timeFormatted = dateFormatter.date(from: timeCheck)
        return dateFormatter.string(from: timeFormatted!)
    }

}

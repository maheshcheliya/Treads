//
//  Extensions.swift
//  Treads
//
//  Created by Mahesh on 06/11/20.
//

import Foundation

extension Double {
    func metersToMiles(places : Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return ((self / 1609.34) * divisor).rounded() / divisor
    }
}
extension Int {
    func formatTimeDurationToString() -> String {
        let durationHours = self / 3600
        let durationMinutes = (self % 3600) / 60
        let durationSeconds = (self % 3600) % 60
//        return String(format: "%02d:%02d:%02d", durationHours, durationMinutes, durationSeconds)
        if durationSeconds < 0 {
            return "00:00:00"
        } else {
            if durationHours == 0 {
                return String(format: "%02d:%02d", durationMinutes, durationSeconds)
            } else {
                return String(format: "%02d:%02d:%02d", durationHours, durationMinutes, durationSeconds)
            }
        }
    }
}
extension NSDate {
    func getDateString() -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self as Date)
        let month = calendar.component(.month, from: self as Date)
        let year = calendar.component(.year, from: self as Date)
        return "\(month)/\(day)/\(year)"
    }
}

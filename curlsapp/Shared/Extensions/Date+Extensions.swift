//
//  Date+Extensions.swift
//  curlsapp
//
//  Created by Leo on 8/5/25.
//

import Foundation

extension Date {
    func formattedWorkoutDate() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: self, to: Date()).day, daysAgo < 7 {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        } else {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: self)
        }
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func formattedFullDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: self)
    }
    
    func formattedShortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}
//
//  Date+Ex.swift
//  EmotionAnalysisApp
//
//  Created by 林 政樹 on 2022/06/30.
//

import Foundation

extension Date {
    //
    func toString(_ format: String = "yyyyMMdd_HHmmssSSS") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.string(from: self)
    }
    
    func getTimer(startDate: Date) -> String {
        let interval = self.timeIntervalSince(startDate)
        let time = Int(interval)
        
        let h = time / 3600 % 24
        let m = time / 60 % 60
        let s = time % 60
        let ms = Int(interval * 100) % 100

        return String(format: "%02d:%02d:%02d.%02d", h, m, s, ms)
    }
}

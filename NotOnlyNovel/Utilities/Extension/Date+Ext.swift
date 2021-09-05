//
//  Date+Ext.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/20.
//

extension Date {

    static func stringToDateTime(_ str: String) -> Date {
        let formatter = DateFormatter()
        if str.split(separator: Character(" ")).count == 3 {
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss Z"
        } else {
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        }
        let _date = formatter.date(from: str)
        if _date == nil {
            return Date()
        } else {
            return _date!
        }
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: self)
    }
    
    func toDateTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    func getElapsedInterval() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else {
            return "a moment ago"
        }
    }
    
}

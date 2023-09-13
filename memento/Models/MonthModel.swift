//
//  MonthModel.swift
//  InfiniteScroll
//
//  Created by Matthew Susko on 2023-08-12.
//

import Foundation
import SwiftUI

struct MonthModel:Identifiable {
    var id:String = ""
    var month:String = ""
    var monthOfTheYear:Int = 0
    var year:Int = 0
    var yearStr: String = ""
    var monthNumStr: String = ""
    var amountOfDays:Int {
        let dateComponents = DateComponents(year: year, month: monthOfTheYear)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
    var spacesBeforeFirst:Int {
        let dateComponents = DateComponents(year: year, month: monthOfTheYear)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        return date.dayNumberOfWeek()!
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
        
    }
}

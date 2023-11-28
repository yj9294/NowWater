//
//  DateHelper.swift
//  NowWater
//
//  Created by yangjian on 2023/10/12.
//

import Foundation

extension Date {
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
}

//
//  DateOfHistory.swift
//  BrowserDemo
//
//  Created by wentilin on 15/6/4.
//  Copyright (c) 2015年 wentilin. All rights reserved.
//

import UIKit

class DateOfHistory: NSObject {
    
    static var today: String?
    
    class func getDate() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MMMdd日  EEEE"
        if let dateString = today {
            if dateString == dateFormatter.stringFromDate(NSDate()) {
                return dateString
            } else {
                today = dateFormatter.stringFromDate(NSDate())
                return today!
            }
        } else {
            today = dateFormatter.stringFromDate(NSDate())
            return today!
        }
    }
}

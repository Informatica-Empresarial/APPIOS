//
//  DKHExtensions.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 6/9/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import MapKit


extension UNUserNotificationCenter {
    
    func scheduleNotification(at date: Date, withTitle title:String,body:String,identifier:String) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content         = UNMutableNotificationContent()
        content.title       = title
        content.body        = body
        content.sound       = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}

extension Date {
    
    func check(withFormat format:String, date:Date)-> String? {
        let dateFormatter: DateFormatter    = DateFormatter()
        dateFormatter.locale                = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat            = format
        return dateFormatter.string(from: date)
    }
    
    func stringFromDate(format:String) -> String? {
        
        
        if let date = check(withFormat: format, date: self) {
            return date
        }
        return nil
    }
    
    func localToUTC() -> String {
        
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormator.calendar = NSCalendar.current
        dateFormator.timeZone = TimeZone.current
        
        let dt = self
        dateFormator.timeZone = TimeZone(abbreviation: "UTC")
        dateFormator.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormator.string(from: dt)
    }
    
    func UTCToLocal() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone  = TimeZone.current
        let seconds = NSTimeZone.local.secondsFromGMT(for: self)
        return self.addingTimeInterval(TimeInterval(seconds))
    }
    
}


extension MKPolyline {
    
    func polyLineWithEncodedString(encodedString: String) -> MKPolyline {
        let bytes = (encodedString as NSString).utf8String
        let length = encodedString.lengthOfBytes(using: String.Encoding.utf8)
        var idx: Int = 0
        
        var count = length / 4
        var coords = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: count)
        var coordIdx: Int = 0
        
        var latitude: Double = 0
        var longitude: Double = 0
        
        while (idx < length) {
            var byte = 0
            var res = 0
            var shift = 0
            
            repeat {
                idx += 1
                byte = bytes![idx] - 0x3F
                res |= (byte & 0x1F) << shift
                shift += 5
            } while (byte >= 0x20)
            
            let deltaLat = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
            latitude += Double(deltaLat)
            
            shift = 0
            res = 0
            
            repeat {
                idx += 1
                byte = bytes![idx] - 0x3F
                res |= (byte & 0x1F) << shift
                shift += 5
            } while (byte >= 0x20)
            
            let deltaLon = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
            longitude += Double(deltaLon)
            
            let finalLat: Double = latitude * 1E-5
            let finalLon: Double = longitude * 1E-5
            
            let coord = CLLocationCoordinate2DMake(finalLat, finalLon)
            coordIdx += 1
            coords[coordIdx] = coord
            
            if coordIdx == count {
                let newCount = count + 10
                let temp = coords
                //coords.deinitialize(count: count)
                //coords.deallocate(capacity: count)
                coords = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: newCount)
                for index in 0..<count {
                    coords[index] = temp[index]
                }
                temp.deinitialize()
                count = newCount
            }
            
        }
        
        let polyLine = MKPolyline(coordinates: coords, count: coordIdx)
        coords.deinitialize()
        
        return polyLine
    }

    

    
}

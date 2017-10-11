//
//  DKHServiceSummary.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/8/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class DKHServiceSummary: NSObject {
    
    var services:[String:Double]!
    var address:String!
    var coordinates:CLLocationCoordinate2D!
    var worker:DKHWorker!
    var selectedTime:Date!
    var currency:String!
    var sosSearch:Bool!
}

//
//  DKHAvailability.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/8/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper
import AlamofireObjectMapper
import Alamofire
import RealReachability


enum DKHServiceStatus {
    case preScheduled
}

class DKHAvailability: Object, Mappable {
    
    dynamic var uuid                    = ""
    var appointment                     = List<DKHAppointment>()
    dynamic var totalPrice              = 0
    dynamic var totalDuration           = 0
    dynamic var serviceStatusString     = ""
    var workers                         = List<DKHWorker>()
    
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    func mapping(map: Map) {
        
        uuid                <- map["uuid"]
        appointment         <- (map["appointment_services"],ArrayTransform<DKHAppointment>())
        totalPrice          <- map["totalPrice"]
        totalDuration       <- map["totalDuration"]
        serviceStatusString <- map["status"]
        workers             <- (map["availableSpecialists"],ArrayTransform<DKHWorker>())
       
        
    }
    
    
    class func getAvailability(endPoint:DKHEndPoint, clousure:@escaping (_ availability:DKHAvailability)->(), errorClosure:@escaping (_ error:String?)->()) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHAvailability>) in
            
            if let availability = response.result.value, response.result.isSuccess {
                
                clousure(availability)
            }else {
                guard let statusCode = response.response?.statusCode, let data = response.data, let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
                    errorClosure("Error")
                    return
                }
                var error:NSError?
                
                if let message = dict?["message"] as? String {
                    error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey:message])
                }
                errorClosure(error?.localizedDescription)
            }
        }
    }
}


enum AppointmentStatus:String {
    case preScheduled   = "pre-scheduled"
    case scheduled      = "scheduled"
    case delivered      = "delivered"
    case canceled       = "canceled"
    case blockedTime    = "blockedTime"
    case empty          = ""
    case inProgress     = "started"
}

class DKHAppointment:Object,Mappable {
    
    dynamic var appointmentUuid = ""
    dynamic var serviceUuid     = ""
    dynamic var price           = ""
    dynamic var count           = 0
    dynamic var service: DKHService?
    
   
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "appointmentUuid"
    }
    
    
    func mapping(map: Map) {
        
        appointmentUuid     <- map["appointmentUuid"]
        serviceUuid         <- map["serviceUuid"]
        price               <- map["price"]
        count               <- map["count"]
        service             <- map["service"]
        
    }
    
}

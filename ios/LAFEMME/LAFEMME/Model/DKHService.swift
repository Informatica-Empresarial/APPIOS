//
//  DKHService.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/2/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper
import AlamofireObjectMapper
import CoreLocation
import Alamofire
import RealReachability
import DateTools
import SVProgressHUD

class DKHService: Object,Mappable {
    
    dynamic var uuid                    = ""
    dynamic var alias                   = ""
    dynamic var name                    = ""
    dynamic var serviceDescription      = ""
    dynamic var imageUuid               = ""
    dynamic var instruction             = ""
    dynamic var currency                = ""
    dynamic var price                   = ""
    dynamic var serviceDurationInMin    = 0.0
    dynamic var serviceEnable           = false
    dynamic var accountUuid             = ""
    var availability                    = List<DKHServiceAvailability>()
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    
    func mapping(map: Map) {
        
        uuid                        <-  map["uuid"]
        alias                       <-  map["alias"]
        name                        <-  map["name"]
        serviceDescription          <-  map["description"]
        imageUuid                   <-  map["imageUrl"]
        instruction                 <-  map["instruction"]
        currency                    <-  map["currency"]
        price                       <-  map["price"]
        serviceDurationInMin        <-  map["minutes_duration"]
        serviceEnable               <-  map["enabled"]
        accountUuid                 <-  map["accountUuid"]
        availability                <-  (map["serviceAvailabilities"],ArrayTransform<DKHServiceAvailability>())
        
    }
    
    class func all(endPoint:DKHEndPoint, closure:@escaping (_ services:[DKHService]?)->()) {
        

        let status  =  RealReachability.sharedInstance().currentReachabilityStatus()
        if status == .RealStatusNotReachable {
            print("no reach")
            DKHService.eventsFromDataBase(closure: closure)
        }else {
            print("reach")
            DKHService.servicesFromBackend(endPoint: endPoint, closure: { (sucessfull) in
                print("success")

                DKHService.eventsFromDataBase(closure: closure)
            })
        }
        
    }
    
    private class func eventsFromDataBase(closure:@escaping (_ services:[DKHService])->()) {
        Realm.update { (realm) in
            //            let sortProperties = [SortDescriptor(property: "startDate", ascending: true)/*, SortDescriptor(property: "startTime", ascending: true)*/]
            print("database")
            let services = realm.objects(DKHService.self)
            if services.count > 0 {
                let array = Array(services)
                closure(array)
            }else{
                closure([DKHService]())
            }
        }
    }
    
    
    class func servicesFromBackend(endPoint:DKHEndPoint,closure:@escaping (_ successfull:Bool)->()) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseArray { (response:DataResponse<[DKHService]>) in
            print("request")
            if let services = response.result.value, response.result.isSuccess {
            print("services")
                Realm.update(updateClosure: { (realm) in
                    realm.delete(realm.objects(DKHService.self))
                    realm.add(services, update: true)
                })
                closure(true)
                
            }else {
                closure(false)
            }
        }
    }
    
    
    class func getServices(endPoint:DKHEndPoint,clousure:@escaping ((_ services:[DKHService]?,_ error:Error?)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseArray { (response:DataResponse<[DKHService]>) in
            
            if let services = response.result.value, response.result.isSuccess {
                Realm.update(updateClosure: { (realm) in
                    realm.add(services, update: true)
                })
                clousure(services, nil)
            }else {
                guard let statusCode = response.response?.statusCode, let data = response.data, let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
                    clousure(nil,nil)
                    return
                }
                var error:NSError?
                
                if let message = dict?["message"] as? String {
                    error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey:message])
                }
                clousure(nil,error)
            }
        }
    }
    
}

class DKHServiceAvailability:Object, Mappable {
    
    dynamic var uuid                = ""
    dynamic var availabilityEnable  = false
    dynamic var lat                 = 0.0
    dynamic var lng                 = 0.0
    dynamic var radius              = 0.0
    dynamic var serviceUuid         = ""
    
    var coordinates:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        uuid                <- map["uuid"]
        availabilityEnable  <- map["enabled"]
        lat                 <- map["lat"]
        lng                 <- map["lng"]
        radius              <- map["radius"]
        serviceUuid         <- map["serviceUuid"]
        
    }
    
}

class DKHAppointmentRating:Object,Mappable {
    
    dynamic var uuid            = ""
    dynamic var rating          = 0
    dynamic var comments        = ""
    dynamic var appointmentUuid = ""
    dynamic var userUuid        = ""
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        uuid                <- map["uuid"]
        rating              <- map["rating"]
        comments            <- map["comments"]
        appointmentUuid     <- map["appointmentUuid"]
        userUuid            <- map["userUuid"]
    }
    
}




class DKHServiceAppointment:Object, Mappable {
    
    dynamic var uuid        = ""
    dynamic var status      = ""
    dynamic var startDate   = Date()
    dynamic var endDate     = Date()
    dynamic var latitude    = 0.0
    dynamic var longitude   = 0.0
    dynamic var address     = ""
    dynamic var hasDiscount = false
    dynamic var discount    = ""
    dynamic var currency    = ""
    dynamic var totalPrice  = ""
    var appointment         = List<DKHAppointment>()
    var ratings             = List<DKHAppointmentRating>()
    dynamic var worker:DKHWorker?
    dynamic var customer:DKHCustomer?
    
    
    var appointmentStatus:AppointmentStatus {
        return AppointmentStatus(rawValue: status)!
    }
    
    var appointmentCoordinates:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    override static func ignoredProperties() -> [String] {
        return ["appointmentStatus","appointmentCoordinates"]
    }
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        uuid            <- map["uuid"]
        status          <- map["status"]
        startDate       <- (map["startDateTime"],DKHDateTransform())
        endDate         <- (map["endDateTime"],DKHDateTransform())
        latitude        <- map["location.lat"]
        longitude       <- map["location.lng"]
        address         <- map["location.address"]
        hasDiscount     <- map["hasDiscountCoupon"]
        discount        <- map["discountCoupon"]
        currency        <- map["currency"]
        totalPrice      <- map["totalPrice"]
        appointment     <- (map["appointmentServices"],ArrayTransform<DKHAppointment>())
        worker          <- map["specialist"]
        ratings         <- (map["appointmentRatings"],ArrayTransform<DKHAppointmentRating>())
        customer        <- map["customer"]
        
    }
    
    
    class func preScheduleAppointment(endPoint:DKHEndPoint, clousure:@escaping ((_ summary:DKHServiceAppointment?,_ error:String?)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHServiceAppointment>) in
            
            if let summary = response.result.value, response.result.isSuccess, response.response?.statusCode == 200 {
                clousure(summary, nil)
                
            }else {
                guard let statusCode = response.response?.statusCode, let data = response.data, let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
                    clousure(nil,nil)
                    return
                }
                var error:NSError?
                
                if let message = dict?["message"] as? String {
                    error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey:message])
                }
                clousure(nil,error?.localizedDescription)
            }
        }
    }
    
    
    class func scheduleAppointment(endPoint:DKHEndPoint,clousure:@escaping ((_ success:Bool)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHServiceAppointment>) in
            
            if let _ = response.result.value, response.result.isSuccess, response.response?.statusCode == 200 {
                clousure(true)
                
            }else {
                clousure(false)
                //clousure(nil,response.error?.localizedDescription)
            }
        }
        
    }
    
    class func cancelAppointment(endPoint:DKHEndPoint,clousure:@escaping ((_ success:Bool)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHServiceAppointment>) in
            
            if let _ = response.result.value, response.result.isSuccess {
                clousure(true)
                
            }else {
                clousure(false)
                //clousure(nil,response.error?.localizedDescription)
            }
        }
        
    }
    
    class func all(endPoint:DKHEndPoint, closure:@escaping (_ appointments:[DKHServiceAppointment]?)->()) {
        
        
        let status  =  RealReachability.sharedInstance().currentReachabilityStatus()
        if status == .RealStatusNotReachable {
            DKHServiceAppointment.appointmentsFromDataBase(closure: closure)
        }else {
            DKHServiceAppointment.getUserAppointments(endPoint: endPoint, closure: { (sucessfull, errorMessage) in
                SVProgressHUD.dismiss()
                if !sucessfull {
                    
                   SVProgressHUD.showInfo(withStatus: errorMessage)
                }
                 DKHServiceAppointment.appointmentsFromDataBase(closure: closure)
            })
        }
        
    }
    
    private class func appointmentsFromDataBase(closure:@escaping (_ services:[DKHServiceAppointment])->()) {
        Realm.update { (realm) in
            
            let services = realm.objects(DKHServiceAppointment.self)
            if services.count > 0 {
                let array = Array(services)
                closure(array)
            }else{
                closure([DKHServiceAppointment]())
            }
        }
    }
    
    
    class func getUserAppointments(endPoint:DKHEndPoint, closure:@escaping ((_ successfull:Bool, _ errorMessage:String?)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseArray { (response:DataResponse<[DKHServiceAppointment]>) in
            
            if let appointments = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                Realm.update(updateClosure: { (realm) in
                    realm.delete(realm.objects(DKHServiceAppointment.self))
                    realm.add(appointments, update: true)
                })
                closure(true,nil)
            }else {
                
                guard let statusCode = response.response?.statusCode, let data = response.data, let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
                    closure(false,nil)
                    return
                }
                var error:NSError?
                
                if let message = dict?["message"] as? String {
                    error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey:message])
                }

                closure(false, error?.localizedDescription)
            }
        }
    }
    
    class func finishAppointment(endPoint:DKHEndPoint,closure:@escaping ((_ successfull:Bool,_ appointment:DKHServiceAppointment?)->())) {
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHServiceAppointment>) in
            if let appointment = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                Realm.update(updateClosure: { (realm) in
                    realm.add(appointment, update: true)
                })
                closure(true,appointment)
            }else {
                closure(false,nil)
                print("error")
            }
        }
    }
    
    class func startAppointment(endPoint:DKHEndPoint,closure:@escaping ((_ successfull:Bool,_ appointment:DKHServiceAppointment?)->())) {
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHServiceAppointment>) in
            if let appointment = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                Realm.update(updateClosure: { (realm) in
                    realm.add(appointment, update: true)
                })
                closure(true,appointment)
            }else {
                closure(false,nil)
                print("error")
            }
        }
    }

    
    
    class func rateAppointment(endPoint:DKHEndPoint,closure:@escaping ((_ successfull:Bool,_ appointment:DKHServiceAppointment?)->())) {
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHServiceAppointment>) in
            if let appointment = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                Realm.update(updateClosure: { (realm) in
                    realm.add(appointment, update: true)
                })
                closure(true,appointment)
            }else {
                closure(false,nil)
                print("error")
            }
        }
    }
    
}

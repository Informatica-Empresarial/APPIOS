//
//  DKHUser.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/13/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import ObjectMapper
import AlamofireObjectMapper
import RealmSwift
import Alamofire
import CoreLocation
import DateTools

class RealmString: Object {
    dynamic var string = ""
    
}

class DKHWorkerDates:Object,Mappable {
    dynamic var date = Date()
    
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        date         <- (map["date"],DKHDateTransform())
        
    }
}

class DKHUser: Object, Mappable {
    
    dynamic var firstname           = ""
    dynamic var lastname            = ""
    dynamic var uuid                = ""
    dynamic var email               = ""
    dynamic var phoneNumber         = ""
    dynamic var token               = ""
    dynamic var accountUuid         = "00000000-0000-0000-0000-000000000000"
    dynamic var address             = ""
    private let backingStartDates   = List<RealmString>()
    dynamic var imageUrl            = ""
    dynamic var userDescripton      = ""
    dynamic var SOS                 = false
    var groups                      = List<DKHGroups>()
    var permissions                 = List<RealmString>()
    private var userRoles           = List<RealmString>()
    dynamic var city                = ""
    
    var userRole:DKHUserRoles {
        
        guard let firstRole = userRoles.first else {
            return .undefined
        }
        if let role = DKHUserRoles(rawValue: firstRole.string) {
            return role
        }else {
            return .undefined
        }
    }
    
    private var rolesArray:[String] {
        get {
            return userRoles.map({$0.string})
        }
        set {
            userRoles.removeAll()
            userRoles.append(objectsIn: newValue.map({RealmString(value:[$0])}))
        }
    }
    
    private var permissionsArray:[String] {
        get {
            return permissions.map({$0.string})
        }
        set {
            permissions.removeAll()
            permissions.append(objectsIn: newValue.map({RealmString(value:[$0])}))
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["permissionsArray","rolesArray"]
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    
    func mapping(map: Map) {
        
        firstname               <- map["firstName"]
        lastname                <- map["lastName"]
        uuid                    <- map["uuid"]
        email                   <- map["email"]
        phoneNumber             <- map["phoneNumber"]
        token                   <- map["token"]
        accountUuid             <- map["accountUuid"]
        groups                  <- (map["groups"],ArrayTransform<DKHGroups>())
        address                 <- map["address"]
        imageUrl                <- map["avatar"]
        userDescripton          <- map["description"]
        permissions             <- map["permissions"]
        rolesArray              <- map["roles"]
        SOS                     <- map["SOS"]
        city                    <- map["city"]
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    class var isLoggedIn:Bool  {
        return (currentUser != nil)
    }
    
    class var currentUser:DKHUser? {
        var user:DKHUser? = nil
        Realm.update { (realm) in
            user = realm.objects(DKHUser.self).first
        }
        
        return user
    }
    
    class var workerAccount:Bool {
        guard let user = currentUser else {
            return false
        }
        return user.userRole == .ServiceSpecialistUser
    }
    
    
    
    class func updateUserInfo(endPoint:DKHEndPoint,closure:@escaping ((_ sucess:Bool, _ message:String?)->())) {
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHUser>) in
            
            if let user = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                Realm.update(updateClosure: { (realm) in
                    if  let currentUser = realm.objects(DKHUser.self).first {
                        currentUser.address = user.address
                    }
                })
                print(user)
                
                closure(true, nil)
            }else {
                
                guard let statusCode = response.response?.statusCode, let data = response.data, let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
                    closure(false,nil)
                    return
                }
                var error:NSError?
                
                if let message = dict?["message"] as? String {
                    error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey:message])
                }
                closure(false,error?.localizedDescription)
            }
        }

        
    }
    
    
    class func loginFacebook(endPoint:DKHEndPoint,clousure:@escaping ((_ user:DKHUser?,_ error:Error?)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHUser>) in
            
            if let user = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                Realm.update(updateClosure: { (realm) in
                    realm.delete(realm.objects(DKHUser.self))
                })
                user.save()
                print(user)
                
                clousure(user, nil)
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

    
    class func login(endPoint:DKHEndPoint,clousure:@escaping ((_ user:DKHUser?,_ error:Error?)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHUser>) in
            
            if let user = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                Realm.update(updateClosure: { (realm) in
                    realm.delete(realm.objects(DKHUser.self))
                })
                user.save()
                print(user)
                
                clousure(user, nil)
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
    
    class func forgotPassword(endPoint:DKHEndPoint,clousure:@escaping ((_ success:Bool)->())) {
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseJSON(completionHandler: { (response) in
            
            if response.response?.statusCode == 200 {
                clousure(true)
            }else {
                clousure(false)
            }
        })
    }
    
    class func logOut() {
        Realm.update { (realm) in
            realm.delete(realm.objects(DKHUser.self))
        }
    }
    
    class func registerDevice(endPoint:DKHEndPoint,clousure:@escaping ((_ success:Bool)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).validate().responseJSON { response in
            
            if let _ = response.result.value, response.response?.statusCode == 200 {
                
                clousure(true)
            }else {
                clousure(false)
                print("error")
            }
        }
    }
    
    class func deleteDevice(endPoint:DKHEndPoint,clousure:@escaping ((_ success:Bool)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).validate().responseJSON { response in
            if let _ = response.result.value, response.response?.statusCode == 200 {
                clousure(true)
            }else {
                clousure(false)
                print("error")
            }
        }
    }
    
    class func register(endPoint:DKHEndPoint, clousure:@escaping ((_ user:DKHUser?, _ error :Error?)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHUser>) in
            
            if let user = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                user.save()
                print(user)
                clousure(user, nil)
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
    
    class func turnOffSOS(endPoint:DKHEndPoint,closure:@escaping ((_ sucess:Bool)->())) {
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseJSON { (response) in
            if let _ = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                closure(true)
                //  clousure(user, nil)
            }else {
                closure(false)
                print("error")
            }
        }
    }
}


class DKHGroups:Object, Mappable {
    
    dynamic var uuid                = ""
    dynamic var name                = ""
    dynamic var groupDescription    = ""
    dynamic var isSystem            = false
    dynamic var accountUuid         = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        uuid                <-   map["uuid"]
        name                <-   map["name"]
        groupDescription    <-   map["description"]
        isSystem            <-   map["isSystem"]
        accountUuid         <-   map["accountUuid"]
    }
}


class DKHLocation:Object,Mappable {
    
    dynamic var formattedAdrress    = ""
    dynamic var lat                 = 0.0
    dynamic var lng                 = 0.0
    
    var coords:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        formattedAdrress    <- map["formatted_address"]
        lat                 <- map["geometry.location.lat"]
        lng                 <- map["geometry.location.lng"]
    }
    
    // 6.1996001) + "," + String(format:"%f",-75.5711198)
    
    class func getAddressFromCoords(endpoint:DKHEndPoint, complete:@escaping (_ location:[DKHLocation], _ error: Error?)->()){
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: endpoint.parameterEncoding).responseArray(keyPath:"results") { (response:DataResponse<[DKHLocation]>) in
            
            if let location = response.result.value, response.result.isSuccess {
                complete(location, nil)
            }
            
        }
    }
    
    class func getCordsFromAddress(endpoint:DKHEndPoint, complete:@escaping (_ location:[DKHLocation], _ error: Error?)->()){
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: endpoint.parameterEncoding).responseArray(keyPath:"results") { (response:DataResponse<[DKHLocation]>) in
            
            if let location = response.result.value, response.result.isSuccess {
                complete(location, nil)
            }
        }
    }
    
    
    
}

class DKHCustomer:Object,Mappable {
    
    dynamic var firstname           = ""
    dynamic var lastname            = ""
    dynamic var uuid                = ""
    dynamic var email               = ""
    dynamic var phoneNumber         = ""
    dynamic var address             = ""
    dynamic var imageUrl            = ""
    dynamic var userDescripton      = ""
    dynamic var city                = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    
    func mapping(map: Map) {
        
        firstname               <- map["firstName"]
        lastname                <- map["lastName"]
        uuid                    <- map["uuid"]
        email                   <- map["email"]
        phoneNumber             <- map["phoneNumber"]
        address                 <- map["address"]
        imageUrl                <- map["avatar"]
        userDescripton          <- map["description"]
        city                    <- map["city"]
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }

}


class DKHWorker: Object, Mappable {
    
    dynamic var firstname           = ""
    dynamic var lastname            = ""
    dynamic var uuid                = ""
    dynamic var email               = ""
    dynamic var phoneNumber         = ""
    dynamic var accountUuid         = "00000000-0000-0000-0000-000000000000"
    dynamic var address             = ""
    private let backingStartDates   = List<RealmString>()
    dynamic var imageUrl            = ""
    dynamic var userDescripton      = ""
    dynamic var SOS                 = false
    dynamic var latitude            = 0.0
    dynamic var longitude           = 0.0
    var dates                       = List<DKHWorkerDates>()
    var groups                      = List<DKHGroups>()
    var permissions                 = List<RealmString>()
    private var userRoles           = List<RealmString>()
    
    var lastKnowlocation:CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }
    
    var workerDates:[DKHWorkerDates] {
        if dates.count > 0 {
            return Array(dates)
        }
        
        return []
    }
    
    var userRole:DKHUserRoles {
        
        guard let firstRole = userRoles.first else {
            return .undefined
        }
        if let role = DKHUserRoles(rawValue: firstRole.string) {
            return role
        }else {
            return .undefined
        }
    }
    
    private var rolesArray:[String] {
        get {
            return userRoles.map({$0.string})
        }
        set {
            userRoles.removeAll()
            userRoles.append(objectsIn: newValue.map({RealmString(value:[$0])}))
        }
    }
    
    private var permissionsArray:[String] {
        get {
            return permissions.map({$0.string})
        }
        set {
            permissions.removeAll()
            permissions.append(objectsIn: newValue.map({RealmString(value:[$0])}))
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["permissionsArray","rolesArray","workerDates"]
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    
    func mapping(map: Map) {
        
        firstname               <- map["firstName"]
        lastname                <- map["lastName"]
        uuid                    <- map["uuid"]
        email                   <- map["email"]
        phoneNumber             <- map["phoneNumber"]
        accountUuid             <- map["accountUuid"]
        groups                  <- (map["groups"],ArrayTransform<DKHGroups>())
        address                 <- map["address"]
        imageUrl                <- map["avatar"]
        userDescripton          <- map["description"]
        permissions             <- map["permissions"]
        dates                   <- (map["validStartDateTimes"],ArrayTransform<DKHWorkerDates>())
        rolesArray              <- map["roles"]
        SOS                     <- map["SOS"]
        latitude                <- map["lastKnownLocation.lat"]
        longitude               <- map["lastKnownLocation.lng"]
    }
    
    
    class func activateSOS(endPoint:DKHEndPoint, clousure:@escaping ((_ user:DKHWorker?, _ error :Error?)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHWorker>) in
            
            if let worker = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                Realm.update(updateClosure: { (realm) in
                    if  let user = realm.objects(DKHUser.self).first {
                        user.SOS   = worker.SOS
                        realm.add(user, update: true)
                    }
                })
                clousure(worker, nil)
            }else {
                clousure(nil,response.result.error)
                print("error")
            }
        }
    }
    
    class func updateLocation(endPoint:DKHEndPoint, clousure:@escaping ((_ user:DKHWorker?, _ error :Error?)->())) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHWorker>) in
            
            if let worker = response.value, response.result.isSuccess, response.response?.statusCode == 200 {
                clousure(worker, nil)
            }else {
                clousure(nil,response.result.error)
                print("error")
            }
        }
    }
}




//
//  DKHGlobalSettings.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/13/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper
import RealReachability
import Alamofire
import AlamofireObjectMapper
import CoreLocation

class DKHGlobalSettings: Object,Mappable {
    dynamic var permissionSystemName:DKHPermissionSystemNames?
    dynamic var rolesSystemName:DKHRolesSystemName?
    
    var permissions             = List<DKHConstantPermissions>()
    var roles                   = List<DKHRoles>()
    
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        roles                   <- (map["ROLES"],ArrayTransform<DKHRoles>())
        permissions             <- (map["PERMISSIONS"],ArrayTransform<DKHConstantPermissions>())
        permissionSystemName    <-  map["PERMISSION_SYSTEM_NAMES"]
    }
    
    class func all(endPoint:DKHEndPoint, closure:@escaping (_ settings:DKHGlobalSettings?)->()) {
        
        let status  =  RealReachability.sharedInstance().currentReachabilityStatus()
        if status == .RealStatusNotReachable {
            DKHGlobalSettings.settingsFromDataBase(endPoint:endPoint,closure: closure)
        }else {
            DKHGlobalSettings.getAppConstant(endPoint: endPoint, closure: { (globalSettings) in
                DKHGlobalSettings.settingsFromDataBase(endPoint:endPoint,closure: closure)
            })
        }
    }
    
    class func settingsFromDataBase(endPoint:DKHEndPoint,closure:@escaping (_ settings:DKHGlobalSettings?)->()) {
        Realm.update { (realm) in
            let settings = realm.objects(DKHGlobalSettings.self)
            if settings.count != 0 {
                closure(settings.first)
            }else {
                getAppConstant(endPoint: endPoint, closure: closure)
            }
        }
    }
    
    private class func getAppConstant(endPoint:DKHEndPoint,closure:@escaping (_ settings:DKHGlobalSettings?)->()) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseObject { (response:DataResponse<DKHGlobalSettings>) in
            if let globalSettings = response.value, response.result.isSuccess {
                Realm.update(updateClosure: { (realm) in
                    realm.add(globalSettings)
                })
                closure(globalSettings)
                
            }else {
                closure(nil)
                print("error")
            }
        }
        
    }
    
}

class DKHPermissionSystemNames:Object,Mappable {
    
    dynamic var MODIFY_ACCOUNT_INFORMATION  = ""
    dynamic var MODIFY_ADMIN_USERS          = ""
    dynamic var MODIFY_NON_ADMIN_USERS      = ""
    dynamic var SOLUTION_MANAGER            = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        MODIFY_ACCOUNT_INFORMATION  <- map["MODIFY_ACCOUNT_INFORMATION"]
        MODIFY_ADMIN_USERS          <- map["MODIFY_ADMIN_USERS"]
        MODIFY_NON_ADMIN_USERS      <- map["MODIFY_NON_ADMIN_USERS"]
        SOLUTION_MANAGER            <- map["SOLUTION_MANAGER"]
        
    }
}

class DKHConstantPermissions:Object,Mappable {
    
    dynamic var systemName              = ""
    dynamic var friendlyName            = ""
    dynamic var rolesDescription        = ""
    // var permissions                     = List<RelamString>()
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        systemName              <- map["systemName"]
        friendlyName            <- map["friendlyName"]
        rolesDescription        <- map["description"]
        
    }
}

class DKHRolesSystemName:Object,Mappable {
    
    dynamic var accountAdmin            =   ""
    dynamic var userAdmin               =   ""
    dynamic var studioSolutionManger    =   ""
    dynamic var mobileEndUser           =   ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        accountAdmin            <- map["ACCOUNT_ADMIN"]
        userAdmin               <- map["USER_ADMIN"]
        studioSolutionManger    <- map["STUDIO_SOLUTION_MANAGER"]
        mobileEndUser           <- map["MOBILE_END_USER"]
    }
}


enum DKHUserRoles:String {
    case UserAdmin              = "UserAdmin"
    case ServiceSpecialistUser  = "ServiceSpecialistUser"
    case CustomerUser           = "CustomerUser"
    case undefined              = ""
    
}

class DKHRoles:Object,Mappable {
    
    dynamic var systemName              = ""
    dynamic var friendlyName            = ""
    dynamic var rolesDescription        = ""
    
    var userRole:DKHUserRoles {
        guard let role = DKHUserRoles(rawValue: systemName) else {
            return .undefined
        }
        return role
    }
    
    override class func ignoredProperties() -> [String] {
        return ["userRole"]
    }
    //var permissions                     = List<RelamString>()
    
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        // permissions             <- (map["permissions"],ArrayTransform<RelamString>())
        systemName              <- map["systemName"]
        friendlyName            <- map["friendlyName"]
        rolesDescription        <- map["description"]
    }
}

class DKHAccounts:Object,Mappable {
    
    static let sharedInstance = DKHAccounts()
    
    dynamic var uuid        = ""
    dynamic var name        = ""
    dynamic var fileHost    = ""
    dynamic var imagesUrl   = ""
    
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        uuid                <- map["uuid"]
        name                <- map["name"]
        fileHost            <- map["fileServerHostName"]
    }
    
    
}

class DKHCity:Object, Mappable {
    
    dynamic var cityName        = ""
    dynamic var lat             = 0.0
    dynamic var lng             = 0.0
    dynamic var country         = ""
    dynamic var selectable      = false
    
    
    var coordinates:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        cityName                <- map["name"]
        lat                     <- map["lat"]
        lng                     <- map["lng"]
        country                 <- map["country"]
        selectable              <- map["selectable"]
    }
    
    
    class func all(endPoint:DKHEndPoint, closure:@escaping (_ cities:[DKHCity]?)->()) {
        
        let status  =  RealReachability.sharedInstance().currentReachabilityStatus()
        if status == .RealStatusNotReachable {
            DKHCity.citiesFromDataBase(closure: closure)
        }else {
            //DKHCity.citiesFromDataBase(closure: closure)
            DKHCity.citiesFromBackend(endPoint: endPoint, closure: { (sucessfull,cities) in
                closure(cities)
                //DKHCity.citiesFromDataBase(closure: closure)
            })
        }
        
    }
    
    class func citiesFromDataBase(closure:@escaping (_ cities:[DKHCity])->()) {
        Realm.update { (realm) in
            let cities = realm.objects(DKHCity.self)
            if cities.count > 0 {
                let array = Array(cities)
                closure(array)
            }else{
                closure([DKHCity]())
            }
        }
    }
    
    
    class func citiesFromBackend(endPoint:DKHEndPoint,closure:@escaping (_ successfull:Bool,_ cities:[DKHCity]?)->()) {
        
        Alamofire.request(endPoint.url, method: endPoint.method, parameters: endPoint.parameters, encoding: endPoint.parameterEncoding, headers: endPoint.customHeaders).responseArray { (response:DataResponse<[DKHCity]>) in
            
            if let cities = response.result.value, response.result.isSuccess {
                Realm.update(updateClosure: { (realm) in
                    realm.delete(realm.objects(DKHCity.self))
                    realm.add(cities)
                    
                })
                closure(true,cities)
               
            }else {
                closure(false, nil)
            }
        }
    }
    
    
}

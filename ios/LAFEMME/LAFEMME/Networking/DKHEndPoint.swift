//
//  DKHEndPoint.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/7/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import CoreLocation

protocol APIEndpoint {
    var baseUrl:URL { get }
    var path: String { get }
    var method:HTTPMethod { get }
    var parameters:[String:Any]? { get }
    var parameterEncoding: ParameterEncoding { get }
    var customHeaders: [String:String]? { get }
}

extension APIEndpoint {
    var url:URL {
        return baseUrl.appendingPathComponent(path)
    }
}

enum DKHEndPoint {
    
    case login(email:String,password:String)
    case loginFacebook(token:String)
    case register(email:String,password:String,firstname:String,lastname:String,phoneNumber:String,city:String,address:String,userDocumentId:String?)
    case resetPassword(newPassword:String,confirmNewPassword:String)
    case resetPasswordWithEmail(email:String)
    case updateUserInfo(address:String,phone:String,name:String,email:String)
    
    
    case getUserLocation(coords:CLLocationCoordinate2D,sensor:Bool)
    case getUserLocationByAddress(address:String)
    case getServices(location:CLLocationCoordinate2D?,currency:String?,city:String?)
    case getCities(country:String?,city:String?)
    case getAvailability(workerUuid:String?,fromDate:String?,toDate:String?,coordinates:CLLocationCoordinate2D,services:[String:Double])
    case getSosAvailability(workerUuid:String?,coordinates:CLLocationCoordinate2D,services:[String:Double])
    case appointment(startDateTime:String,coustomerUuid:String,workerUuid:String,location:CLLocationCoordinate2D,address:String,hasDiscountCoupon:Bool,discount:String,services:[String:Double])
    case appointments(workerUuid:String)
    
    case scheduleAppointment(appointmentUuid:String,isSos:Bool)
    case cancelAppointment(appointmentUuid:String)
    case finishAppointment(appointmentUuid:String)
    case startAppointment(appointmentUuid:String)
    
    case globalSettings()
    
    case registerDevice(deviceToken:String)
    case deleteDevice(deviceToken:String)
    
    case tongleSOS(location:CLLocationCoordinate2D?)
    case lastLocation(location:CLLocationCoordinate2D)
    case turnOffSOS()
    
    case rateAppointment(appointmentUuid:String,rate:Int,comments:String)
    case forgotPassword(email:String)
    
    
    case getDirections()
    
    
    
}


extension DKHEndPoint:APIEndpoint {
    
    
    var baseUrl:URL {
        switch  self {
        case .getUserLocation(coords: _, sensor: _), .getUserLocationByAddress(address: _):
            return URL(string:"http://maps.googleapis.com/maps/api/geocode/")!
            //case .getAvailability(workerUuid: _, fromDate: _, toDate: _, coordinates: _, services: _):
            //  return URL(string: "http://www.mocky.io/v2/59188d731200004c0c40dbca")!
            
        case .getDirections():
            
            return URL(string:"https://maps.googleapis.com/maps/api/directions/")!
        default:
            return URL(string: "http://api.lafemme.com.co")!
        }
    }
    
    var path:String {
        switch self {
            
        case .login(email: _, password: _):
            return "/sessions"
            
        case .loginFacebook(token:_):
            return "/sessions/facebook"
            
        case .register(email:_,password:_,firstname:_,lastname:_,phoneNumber:_,city:_,address:_,userDocumentId:_):
            return "/users/register"
            
        case .updateUserInfo(address:_,phone:_,name:_,email:_):
            guard let user = DKHUser.currentUser else {
                return ""
            }
            return "/users/\(user.uuid)"
            
        case .resetPassword(newPassword:_,confirmNewPassword:_):
            return "/reset-password"
            
        case .resetPasswordWithEmail(email:_):
            return "/request-password-reset"
            
        case .getServices(location:_,currency:_,city:_):
            return "/services"
            
        case .getCities(country: _, city: _):
            return "/city"
            
        case .getAvailability(workerUuid: _, fromDate: _, toDate: _, coordinates: _, services: _):
            
            return "/appointments/availability"
            
        case .getSosAvailability(workerUuid: _, coordinates: _, services: _):
            return "/appointments/availability/SOS"
            
        case .appointment(startDateTime: _, coustomerUuid: _,workerUuid: _, location: _, address: _, hasDiscountCoupon: _, discount: _, services: _),.appointments(workerUuid: _):
            return "/appointments"
            
        case .scheduleAppointment(appointmentUuid: let appointmentUuid, isSos: _):
            return "appointments/\(appointmentUuid)/schedule"
            
        case .cancelAppointment(appointmentUuid: let appointmentUuid):
            return "appointments/\(appointmentUuid)/cancel"
            
        case .globalSettings():
            return "/constants/mobile"
            
        case .registerDevice(deviceToken: _):
            return "/devices/register"
        case .deleteDevice(deviceToken: _):
            return "/devices/delete"
            
        case .tongleSOS(_):
            guard let user = DKHUser.currentUser else {
                return ""
            }
            
            return "/users/\(user.uuid)/toggleSOS"
        case .lastLocation(location: _):
            guard let user = DKHUser.currentUser else {
                return ""
            }
            return "/users/\(user.uuid)/lastKnownLocation"
            
        case .rateAppointment(appointmentUuid: let appointmentUuid,rate:_,comments:_):
            return "/appointments/\(appointmentUuid)/ratings"
            
        case .forgotPassword(email: _):
            return "/request-password-reset"
        case .finishAppointment(appointmentUuid: let appointmentUuid):
            return "appointments/\(appointmentUuid)/deliver"
            
        case .startAppointment(appointmentUuid: let appointmentUuid):
            return "appointments/\(appointmentUuid)/start"
            
        case .turnOffSOS():
            guard let user = DKHUser.currentUser else {
                return ""
            }
            return "/users/\(user.uuid)/SOS/off"
            
        default:
            return "json"
        }
        
    }
    
    var method: HTTPMethod {
        
        switch self {
        case .login(email: _, password: _), .resetPassword(newPassword: _, confirmNewPassword: _),.resetPasswordWithEmail(email: _),.register(email: _, password: _, firstname: _, lastname: _, phoneNumber: _, city: _, address: _, userDocumentId: _), .getAvailability(workerUuid: _, fromDate: _, toDate: _, coordinates: _, services: _), .appointment(startDateTime: _, coustomerUuid: _,workerUuid: _, location: _, address: _, hasDiscountCoupon: _, discount: _, services: _),.getSosAvailability(workerUuid: _, coordinates: _, services: _),.registerDevice(deviceToken: _), .deleteDevice(deviceToken: _),.rateAppointment(appointmentUuid: _, rate: _, comments: _), .forgotPassword(email: _), .loginFacebook(token: _):
            return .post
            
        case .scheduleAppointment(appointmentUuid: _), .cancelAppointment(appointmentUuid: _), .tongleSOS(_), .lastLocation(location: _),.turnOffSOS(),.finishAppointment(appointmentUuid: _),.startAppointment(appointmentUuid: _), .updateUserInfo(address:_,phone:_,name:_,email:_):
            return .put
        default:
            return .get
        }
    }
    
    var parameters:[String:Any]? {
        
        switch self {
        case .login(email: let email, password: let password):
            return ["email":email,"password":password]
        case .register(email:let email,password:let password,firstname:let firstname,lastname:let lastname,phoneNumber:let phoneNumber,city:let city,address:let address,userDocumentId:let docummentId):
            
            guard let docummentId = docummentId else {
                return ["email":email,"password":password,"accountId":"00000000-0000-0000-0000-000000000000","firstName":firstname,"lastName":lastname,"phoneNumber":phoneNumber,"city":city,"address":address]
            }
            return ["email":email,"password":password,"accountId":"00000000-0000-0000-0000-000000000000","firstName":firstname,"lastName":lastname,"phoneNumber":phoneNumber,"city":city,"address":address,"DNI":docummentId]
            
        case .resetPassword(newPassword: let newPassword, confirmNewPassword: let confirmation):
            return ["newPassword":newPassword,"newPasswordConfirm":confirmation]
        case .resetPasswordWithEmail(email: let email):
            return ["email":email]
        case .getUserLocation(coords: let coords, sensor: let sensor):
            let str = String(format: "%f",coords.latitude) + "," + String(format:"%f",coords.longitude)
            return ["latlng":str,"sensor":sensor]
            
        case .getUserLocationByAddress(address: let address):
            return ["address":address]
            
        case .getServices(location: let coordiantes, currency: _, city: let city):
            
            guard let coordiantes = coordiantes else {
                if let city = city {
                    return ["currency":"COP","city":city,"enabled":true]
                }else {
                    return nil
                }
            }
            return ["lat":coordiantes.latitude,"lng":coordiantes.longitude,"currency":"COP","enabled":"true"]
            
        case .getCities(country: let country, city: let city):
            guard let country = country, let city = city else {
                return nil
            }
            
            return ["country":country, "city":city]
            
        case .getAvailability(workerUuid: _, fromDate: let startDate, toDate: let endDate, coordinates: let coordinates, services: let services):
            var dict = [String:Any]()
            
            
            dict["lat"]         = coordinates.latitude
            dict["lng"]         = coordinates.longitude
            
            if let startDate = startDate, let endDate = endDate {
                dict["fromDateTime"]        = startDate
                dict["toDateTime"]          = endDate
            }
            
            var currentServices = [Any]()
            for (serviceUuid,count) in services {
                var servicesDic = [String:Any]()
                servicesDic["serviceUuid"] = serviceUuid
                servicesDic["count"]       = Int(count)
                currentServices.append(servicesDic)
            }
            
            dict["appointmentServices"] = currentServices
            
            return dict
            
        case .getSosAvailability(workerUuid: _, coordinates: let coordinates, services: let services):
            var dict = [String:Any]()
            
            dict["lat"]         = coordinates.latitude
            dict["lng"]         = coordinates.longitude
            
            var currentServices = [Any]()
            for (serviceUuid,count) in services {
                var servicesDic = [String:Any]()
                servicesDic["serviceUuid"] = serviceUuid
                servicesDic["count"]       = Int(count)
                currentServices.append(servicesDic)
            }
            
            dict["appointmentServices"] = currentServices
            
            return dict
            
        case .appointment(startDateTime: let startDate, coustomerUuid: let customerUuid, workerUuid: let workerUuid, location: let location, address: let address, hasDiscountCoupon: let hasDiscount, discount: let discount, services: let services):
            
            var dict = [String:Any]()
            var currentServices = [Any]()
            for (serviceUuid,count) in services {
                var servicesDic = [String:Any]()
                servicesDic["serviceUuid"] = serviceUuid
                servicesDic["count"]       = Int(count)
                currentServices.append(servicesDic)
            }
            
            dict["discountCoupon"]      = discount
            dict["hasDiscountCoupon"]   = hasDiscount.description
            dict["appointmentServices"] = currentServices
            dict["startDateTime"]       = startDate
            dict["specialistUuid"]      = workerUuid
            dict["customerUuid"]        = customerUuid
            dict["location"]            = ["lat":location.latitude,"lng":location.longitude,"address":address]
            
            return dict
            
        case .appointments(workerUuid: _):
            guard let user = DKHUser.currentUser else {
                return nil
            }
            if user.userRole == .CustomerUser {
                return ["customerUuid":user.uuid]
            }else {
                return ["specialistUuid":user.uuid]
            }
            
        case .scheduleAppointment(appointmentUuid: _, isSos: let sos):
            if sos {
                return ["sos":"true"]
            }else {
                return ["sos":"false"]
            }
            
        case .globalSettings(),.cancelAppointment(appointmentUuid: _):
            return nil
            
        case .registerDevice(deviceToken: let deviceUuid):
            
            guard let user = DKHUser.currentUser, let identifier = Bundle.main.bundleIdentifier else {
                return nil
            }
            
            return ["userUuid":user.uuid,"platform":"IOS","deviceUuid": deviceUuid,"appIdentifier":identifier]
            
        case .deleteDevice(deviceToken: let deviceUuid):
            guard let user = DKHUser.currentUser else {
                return nil
            }
            return ["userUuid":user.uuid,"deviceUuid": deviceUuid]
            
        case .tongleSOS(let location):
            guard let lat = location?.latitude, let long = location?.longitude else {
                return ["":""]
            }
            
            return ["lastKnownLocation":["lat":lat,"lng":long]]
            
        case .lastLocation(location: let location):
            return ["lastKnownLocation":["lat":location.latitude,"lng":location.longitude]]
            
        case .rateAppointment(appointmentUuid: _, rate: let rate,comments:let comments):
            guard let user = DKHUser.currentUser else {
                return nil
            }
            return ["rating":rate,"comments":comments,"userUuid":user.uuid]
        case .forgotPassword(email: let email):
            return ["email":email]
            
        case .finishAppointment(appointmentUuid: _), .startAppointment(appointmentUuid: _):
            return nil
            
        case .getDirections():
            return nil
            
        case .turnOffSOS():
            return ["lastKnownLocation":["lat":0,"lng":0]]
            
        case .updateUserInfo(address:let address,phone:let phone,name:let name,email:let email):
            guard let user = DKHUser.currentUser else {
                return nil
            }
            
            return ["address":address,"uuid":user.uuid,"email":email,"phoneNumber":phone,"firstName":name]
            
        case .loginFacebook(token: let token):
            return ["token":token]
        }
    }
    
    var customHeaders:[String:String]? {
        let pre = NSLocale.preferredLanguages[0]
        switch self {
        case .login(email: _, password: _), .resetPasswordWithEmail(email: _), .getUserLocation(coords: _, sensor: _),.getUserLocationByAddress(address: _),.register(email:_,password:_,firstname:_,lastname:_,phoneNumber:_,city:_,address:_,userDocumentId:_):
            return ["Accept-Language":pre]
        default:
            guard let user = DKHUser.currentUser else {
                return [:]
            }
            return ["Authorization": "Bearer \(user.token)","Content-Type":"application/json","Accept-Language":pre]
        }
    }
    
    var parameterEncoding:ParameterEncoding {
        
        switch self {
        case .getUserLocation(coords: _, sensor: _), .getUserLocationByAddress(address: _),.getServices(location:_,currency:_,city:_), .appointments(workerUuid: _):
            return URLEncoding.default
            
        default:
            return JSONEncoding.default
        }
        
    }
}

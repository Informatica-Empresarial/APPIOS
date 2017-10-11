//
//  DKHRealmHelper.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/7/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import Realm



open class ArrayTransform<T:RealmSwift.Object> : TransformType where T:Mappable {
    public typealias Object = List<T>
    public typealias JSON = Array<Any>
    
    public init(){
    }
    
    public func transformFromJSON(_ value: Any?) -> List<T>? {
        let result = List<T>()
        if let tempArr = value as! Array<Any>? {
            for entry in tempArr {
                let mapper = Mapper<T>()
                let model : T = mapper.map(JSONObject: entry)!//mapper.map(entry)!
                result.append(model)
            }
        }
        return result
    }
    
    public func transformToJSON(_ value: List<T>?) -> Array<Any>? {
        if let value = value, value.count > 0
        {
            var result = Array<Any>()
            
            for entry in value {
                let mapped = Mapper().toJSON(entry)
                result.append(mapped)
            }
            return result
        }
        return nil
    }
    
    

}


open class DKHDateTransform: TransformType {
    
    public typealias Object = Date
    public typealias JSON = String
    
    let dateFormatter: DateFormatter = DateFormatter()
    
    public init() {
        dateFormatter.locale        = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat    = "dd-MM-yyyy"
    }
    
    
    private func check(withFormat format:String, string dateStr:String)-> Date? {
        self.dateFormatter.dateFormat = format
        return self.dateFormatter.date(from:dateStr)
    }
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        
        
        
        if let dateString = value as? String {
            
            if let date = check(withFormat: "yyyy-MM-dd", string: dateString) {
                return date
            }else if let date = check(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", string: dateString) {
                return date
            }else if let date = check(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", string: dateString) {
                return date
            }else if let date = check(withFormat: "dd-MM-yyyy", string: dateString) {
                return date
            }else if let date   = check(withFormat: "yyy-MM-dd'T'HH:mm:ss'Z'", string: dateString) {
                return date
            }
            
        }
        return nil
    }
    
    
    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    
    
}



public extension Object {
    public func save(){
        do{
            let realm = try Realm()
            do{
                try realm.write({ () -> Void in
                    realm.add(self, update:true)
                })
            }catch _{
                print("REALM: impossible save object")
            }
            
        } catch _{
            print("REALM: impossible get the realm default")
        }
    }
    
    public func update(updateClosure:()->()){
        do{
            let realm = try Realm()
            
            do{
                try realm.write({ () -> Void in
                    updateClosure()
                })
            }catch _{
                print("REALM: impossible update object")
            }
            
        } catch _{
            print("REALM: impossible get the realm default")
        }
    }
    
}

public extension Realm {
    
    public class func update(updateClosure:@escaping (_ realm:Realm)->()){
        do{
            let realm = try Realm()
            do{
                try realm.write({ () -> Void in
                    updateClosure(realm)
                })
            }catch _{
                print("REALM: impossible update object")
            }
            
        } catch _{
            print("REALM: impossible get the realm default")
        }
    }
    
}

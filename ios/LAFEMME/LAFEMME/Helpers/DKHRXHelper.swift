//
//  DKHRXHelper.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/7/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//
import RxSwift
import RxCocoa

infix operator <~> : AssignmentPrecedence
//Bidirectional bind RxSwift, swift 3
public func <~> <E,C: ControlPropertyType>(property: C, variable: Variable<E>) -> Disposable where C.E == E? {
    
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            if let n = n{
                variable.value = n
            }
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create([bindToUIDisposable, bindToVariable])
}

extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if (index != nil) {
            self.remove(at: index!)
        }
    }
}

extension String {
    
    func isEmailFormat() -> Bool {
        
        let regexString: String = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        var result : Bool = false
        if !self.isEmpty{
            if  self.isMatchedByRegex(regexExpression: regexString){
                result = true
            }
            
        }
        return result
    }
    
    func isMatchedByRegex(regexExpression :String) -> Bool {
        
        let pattern: String = regexExpression
        
        do{
            
            let internalExpression: NSRegularExpression = try NSRegularExpression (pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let matches = internalExpression.matches(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range:NSMakeRange(0, self.characters.count))
            return matches.count > 0
        } catch{
            return false
        }
    }
}



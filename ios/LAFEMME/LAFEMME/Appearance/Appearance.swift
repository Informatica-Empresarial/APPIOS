//
//  Appearance.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/25/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

enum CustomFont : String {
    case RobotoCondensedRegular = "RobotoCondensed-Regular"
    case RobotoCondensedItalic = "RobotoCondensed-Italic"
    case RobotoCondensedBold = "RobotoCondensed-Bold"
    case QuicksandBold = "Quicksand-Bold"
    
    static let allValues = [RobotoCondensedRegular,RobotoCondensedItalic,RobotoCondensedBold,QuicksandBold]
}

import Foundation
import UIKit

class Appearance: NSObject {
    
    class func configureAppAppearance(){
        configureNavBarTitleFont()
    }
    
    
    class func configureNavBarTitleFont(){
        if let font = UIFont(name: CustomFont.QuicksandBold.rawValue, size:18) {
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font]
        }
        UINavigationBar.appearance().tintColor = UIColor.white
        
    }
    
    class func colorNavigationBar(color:UIColor, navigationBar: UINavigationBar?){
        navigationBar?.setBackgroundImage(UIImage.imageFromColor(color: color), for: UIBarMetrics.default)
        navigationBar?.isTranslucent        = false
        navigationBar?.barTintColor         = color
        
        
        let font = UIFont(name: CustomFont.QuicksandBold.rawValue, size:18)!
        
        navigationBar?.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName: font]
        navigationBar?.shadowImage = UIImage()
    }
    
    
    class func barButtonWithImage(image: UIImage?, target: AnyObject?, action: Selector, color:Bool) -> UIBarButtonItem{
        
        let but: UIButton = UIButton(type: UIButtonType.custom) as UIButton
        but.frame = CGRect(x:0, y:0, width:70, height:30)
        but.backgroundColor = UIColor.clear
        
        if color {
            but.setImage(image?.imageWithTintColor(color: UIColor.white), for: UIControlState.normal)
        }else{
            but.setImage(image, for: UIControlState.normal)
        }
        
        but.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        but.sizeToFit()
        
        let barButton = UIBarButtonItem(customView: but)
        return barButton
        
    }
    
    class func barButtonWithImage(image: UIImage?, target: AnyObject?, color:UIColor = UIColor.white, action: Selector) -> UIBarButtonItem{
        
        let but: UIButton = UIButton(type: UIButtonType.custom) as UIButton
        but.frame = CGRect(x:0, y:0, width:70, height:30)
        but.backgroundColor = UIColor.clear
        but.setImage(image?.imageWithTintColor(color: color), for: UIControlState.normal)
        but.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        but.sizeToFit()
        
        let barButton = UIBarButtonItem(customView: but)
        return barButton
        
    }
    
    class func barButtonWithTitle(title: String?, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        
        let but: UIButton       = UIButton(type: UIButtonType.custom) as UIButton
        but.frame               = CGRect(x:0, y:0, width:50, height:30)
        but.backgroundColor     = UIColor.clear
        but.titleLabel?.font    = UIFont(name: CustomFont.QuicksandBold.rawValue, size: 12)
        but.setTitleColor(UIColor.white, for: UIControlState.normal)
        but.setTitle(title, for: UIControlState.normal)
        but.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        but.sizeToFit()
        
        let barButton = UIBarButtonItem(customView: but)
        
        return barButton
    }
    
    class func barButtonWithTitle(title: String?, textColor: UIColor, target: AnyObject?, action: Selector) -> UIBarButtonItem{
        
        let but: UIButton = UIButton(type: UIButtonType.custom) as UIButton
        but.frame = CGRect(x:0, y:0, width:50, height:30)
        but.backgroundColor = UIColor.clear
        but.titleLabel?.font = UIFont(name: CustomFont.QuicksandBold.rawValue, size: 12)
        but.setTitleColor(textColor, for: UIControlState.normal)
        but.setTitle(title, for: UIControlState.normal)
        but.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        but.sizeToFit()
        
        let barButton = UIBarButtonItem(customView: but)
        
        return barButton
    }
    
    
}

extension UIColor {
    

    
    class func programColor() -> UIColor {
        return UIColor(hex:"#f5475d")
    }
    
    class func programColorLight() -> UIColor {
        return UIColor(hex: "#fa4965")
    }
    
    class func programColorDisable() -> UIColor {
         return UIColor(red: 255.0 / 255.0, green: 91.0 / 255.0, blue: 123.0 / 255.0, alpha: 0.3)
    }
    
    class func sosColor() -> UIColor {
        return UIColor(hex:"#b7b6e0")
    }
    
    class func habitatIIIColor() -> UIColor {
        return  UIColor(red:0.95, green:0.27, blue:0.35, alpha:1.0)
    }
    
    class func commitmentSearchBar() -> UIColor {
        return UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
    }
    
    class func H3BlackColor() -> UIColor {
        return UIColor(red: 24.0/255.0, green: 22.0/255.0, blue: 23.0/255.0, alpha: 1)
    }
    class func H3GrayColor() -> UIColor {
        return UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1)
    }
    
    class func grayLigthColor() -> UIColor {
        return UIColor(white: 165.0 / 255.0, alpha: 1.0)
    }
    
    
    
    class func colorFromString(titleColor:String) -> UIColor {
        switch titleColor.lowercased() {
        case "white":
            return UIColor.white
        case "clear":
            return UIColor.clear
        case "gray":
            return UIColor.H3GrayColor()
        case "lightgray":
            return UIColor.grayLigthColor()
        case "black":
            return UIColor.H3BlackColor()
        case "programLight":
            return UIColor.programColorLight()
        case "program":
            return UIColor.programColor()
        case "program_disable":
            return UIColor.programColorDisable()
        case "sos":
            return UIColor.sosColor()
        case "habitat":
            return UIColor.habitatIIIColor()
        case "commitmentsearch":
            return UIColor.commitmentSearchBar()
        default:
            return UIColor.white
        }
        
    }
    
    func colorString() -> String{
        switch self {
        case UIColor.white:
            return "white"
        case UIColor.clear:
            return "clear"
        case UIColor.H3GrayColor():
            return "gray"
        case UIColor.grayLigthColor():
            return "lightgray"
        case UIColor.H3BlackColor():
            return "black"
        case UIColor.programColor():
            return "program"
        case UIColor.sosColor():
            return "sos"

        default:
            return "clear"
        }
    }
    
    
    convenience init(hex: String, alpha: CGFloat = 1) {
        assert(hex[hex.startIndex] == "#", "Expected hex string of format #RRGGBB")
        
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1  // skip #
        
        var rgb: UInt32 = 0
        scanner.scanHexInt32(&rgb)
        
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16)/255.0,
            green: CGFloat((rgb &   0xFF00) >>  8)/255.0,
            blue:  CGFloat((rgb &     0xFF)      )/255.0,
            alpha: alpha)
    }
}


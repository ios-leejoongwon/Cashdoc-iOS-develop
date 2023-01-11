//
//  UIDevice+Extensions.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import AudioToolbox

extension UIDevice {
    static func vibrate() {
        switch UIDevice.current.modelName {
        case "iPhone 6s", "iPhone 6s Plus", "iPhone 7", "iPhone 7 Plus", "iPhone 8", "iPhone 8 Plus", "iPhone X":
            AudioServicesPlaySystemSound(SystemSoundID(1102))
        default:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = String(validatingUTF8: NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)!.utf8String!)!
        
        switch identifier {
        // iPhone
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone4"
        case "iPhone4,1": return "iPhone4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone5"
        case "iPhone5,3", "iPhone5,4": return "iPhone5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone5s"
        case "iPhone7,2": return "iPhone6"
        case "iPhone7,1": return "iPhone6Plus"
        case "iPhone8,1": return "iPhone6s"
        case "iPhone8,2": return "iPhone6sPlus"
        case "iPhone9,1", "iPhone9,3": return "iPhone7"
        case "iPhone9,2", "iPhone9,4": return "iPhone7Plus"
        case "iPhone8,4": return "iPhoneSE"
        case "iPhone10,1", "iPhone10,4": return "iPhone8"
        case "iPhone10,2", "iPhone10,5": return "iPhone8Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhoneX"
        case "iPhone11,2": return "iPhoneXS"
        case "iPhone11,4", "iPhone11,6": return "iPhoneXSMax"
        case "iPhone11,8": return "iPhoneXR"
        case "iPhone12,1": return "iPhone11"
        case "iPhone12,3": return "iPhone11Pro"
        case "iPhone12,5": return "iPhone11ProMax"
        case "iPhone12,8": return "iPhoneSE2"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
            
        // iPad
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return "iPad Air"
        case "iPad5,3", "iPad5,4":
            return "iPad Air 2"
        case "iPad6,11", "iPad6,12":
            return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":
            return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":
            return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":
            return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":
            return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":
            return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":
            return "iPad Pro 10.5 Inch"
            
        // Simulator
        case "i386", "x86_64":
            return "Simulator"
        default:                                        return identifier
        }
    }
}

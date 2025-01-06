import UIKit

extension UIDevice {
    static var isIphoneProMax: Bool { // iPhone 15 Plus, iPhone 15 Pro Max
        return UIScreen.main.bounds.height >= 896 && UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIphoneBelowX: Bool {
        return UIScreen.main.bounds.height < 812 && UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIpadMini: Bool {
        let screenSize = UIScreen.main.bounds.size
        return (screenSize.height == 1024 && screenSize.width == 768) || // iPad Mini 1-4
               (screenSize.height == 1133 && screenSize.width == 744) // iPad Mini 5-6
    }
    
    static var isIpad9Inch: Bool {
        let screenSize = UIScreen.main.bounds.size
        return (screenSize.height == 1112 || screenSize.width == 834) // iPad Pro 10.5", iPad Air 10.5"
    }
    
    static var isIpad10Inch: Bool {
        let screenSize = UIScreen.main.bounds.size
        return (screenSize.height == 1180 || screenSize.width == 820) // iPad Air 4th Gen (10.9"), iPad 10th Gen (10.9")
    }
    
    static var isIpad11Inch: Bool {
        let screenSize = UIScreen.main.bounds.size
        return (screenSize.height == 1194 || screenSize.width == 834) // iPad Pro 11"
    }
    
    static var isIpad12Inch: Bool {
        let screenSize = UIScreen.main.bounds.size
        return (screenSize.height == 1366 || screenSize.width == 1024) // iPad Pro 12.9"
    }
    
    static var isIpadAir4: Bool {
        let screenSize = UIScreen.main.bounds.size
        return (screenSize.height == 1180 || screenSize.width == 820) // iPad Air 4th Gen (10.9")
    }
    
    static var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

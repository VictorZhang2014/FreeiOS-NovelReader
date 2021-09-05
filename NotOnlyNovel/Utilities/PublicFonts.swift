import Foundation

extension UIFont {
    
    //private lazy var fontsArray = ["Times New Roman","Helvetica", "Arial Rounded MT Bold","Snell Roundhand","Papyrus","Arial","Kannada MN","Helvetica Neue"]
    
    
    public static func ArialRoundedMTBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Arial Rounded MT Bold", size: size)
    }
    
    public static func Avenir(size: CGFloat) -> UIFont? {
        return UIFont(name: "Arial", size: size)
    }
    
    public static func AvenirBlack(size: CGFloat) -> UIFont? {
        return UIFont(name: "Avenir Black", size: size)
    }
    
    public static func AvenirMedium(size: CGFloat) -> UIFont? {
        return UIFont(name: "Avenir Medium", size: size)
    }
    
    public static func AvenirHeavy(size: CGFloat) -> UIFont? {
        return UIFont(name: "Avenir Heavy", size: size)
    }
    
    public static func HelveticaNeue(size: CGFloat) -> UIFont? {
        return UIFont(name: "Helvetica Neue", size: size)
    }
    
}

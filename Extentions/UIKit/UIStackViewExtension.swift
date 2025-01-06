

#if canImport(UIKit) && (os(iOS) || os(tvOS))
import UIKit

public extension UIStackView {
    
    /**
     Shared Files: Add many arranged subviews as array.
     
     - parameter subviews: Array of `UIView` objects.
     */
    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { addArrangedSubview($0) }
    }
    
    /**
     Shared Files: Remove all arranged subviews.
     */
    func removeArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
#endif


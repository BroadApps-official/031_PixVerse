

#if canImport(UIKit) && (os(iOS) || os(tvOS))
import UIKit

extension UIView {
    
    /**
     Shared Files: Init `UIView` object with background color.
     
     - parameter backgroundColor: Color which using for background.
     */
//    public convenience init(backgroundColor color: UIColor) {
//        self.init()
//        backgroundColor = color
//    }
    
    // MARK: - Helpers
    /**
     Shared Files: Get controller, on which place current view.
     
     - Warning: Use with caution and only where necessary. This method can break the view hierarchy, so apply it primarily to top-level views. It does not work well with scrollView
     */
    func makeInvisible() {
        DispatchQueue.main.async {
            let field = UITextField()
            field.isSecureTextEntry = true
            self.addSubview(field)
            field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.layer.superlayer?.addSublayer(field.layer)
            field.layer.sublayers?.first?.addSublayer(self.layer)
        }
    }
    
    /**
     Shared Files: Get controller, on which place current view.
     
     - warning:
     If view not added to any controller, return nil.
     */
    open var viewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    /**
     Shared Files: Add many subviews as array.
     
     - parameter subviews: Array of `UIView` objects.
     */
    open func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }

    public func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
    
    /**
     Shared Files: Remove all subviews.
     */
    open func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    /**
     Shared Files: Take screenshoot of view as `UIImage`.
     */
    open var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /**
     Shared Files: If view has LTR interface.
     */
    open var ltr: Bool { effectiveUserInterfaceLayoutDirection == .leftToRight }
    
    /**
     Shared Files: If view has TRL interface.
     */
    open var rtl: Bool { effectiveUserInterfaceLayoutDirection == .rightToLeft }
    
    // MARK: - Layout
    
    /**
     Shared Files: Set center X of current view to medium width of superview.
     
     - warning:
     If current view have not superview, center X is set to zero.
     */
    open func setXCenter() {
        center.x = (superview?.frame.width ?? 0) / 2
    }
    
    /**
     Shared Files: Set center Y of current view to medium height of superview.
     
     - warning:
     If current view have not superview, center Y is set to zero.
     */
    open func setYCenter() {
        center.y = (superview?.frame.height ?? 0) / 2
    }
    
    /**
     Shared Files: Set center of current view to center of superview.
     
     - warning:
     If current view have not superview, center is set to zero.
     */
    open func setToCenter() {
        setXCenter()
        setYCenter()
    }
    
    // MARK: Readable Content Guide
    
    /**
     Shared Files: Margins of readable frame.
     */
    open var readableMargins: UIEdgeInsets {
        let layoutFrame = readableContentGuide.layoutFrame
        return UIEdgeInsets(
            top: layoutFrame.origin.y,
            left: layoutFrame.origin.x,
            bottom: frame.height - layoutFrame.height - layoutFrame.origin.y,
            right: frame.width - layoutFrame.width - layoutFrame.origin.x
        )
    }
    
    /**
     Shared Files: Readable width of current view without horizontal readable margins.
     */
    open var readableWidth: CGFloat {
        return readableContentGuide.layoutFrame.width
    }
    
    /**
     Shared Files: Readable height of current view without vertical readable margins.
     */
    open var readableHeight: CGFloat {
        return readableContentGuide.layoutFrame.height
    }
    
    /**
     Shared Files: Readable frame of current view without vertical and horizontal readable margins.
     */
    open var readableFrame: CGRect {
        let margins = readableMargins
        return CGRect.init(x: margins.left, y: margins.top, width: readableWidth, height: readableHeight)
    }
    
    // MARK: Layout Margins Guide
    
    /**
     Shared Files: Width of current view without horizontal layout margins.
     */
    open var layoutWidth: CGFloat {
        // ver 1
        // Depricated becouse sometimes return invalid size
        //return layoutMarginsGuide.layoutFrame.width
        
        // ver 2
        return frame.width - layoutMargins.left - layoutMargins.right
    }
    
    /**
     Shared Files: Height of current view without vertical layout margins.
     */
    open var layoutHeight: CGFloat {
        // ver 1
        // Depricated becouse sometimes return invalid size
        //return layoutMarginsGuide.layoutFrame.height
        
        // ver 2
        return frame.height - layoutMargins.top - layoutMargins.bottom
    }
    
    /**
     Shared Files: Frame of current view without horizontal and vertical layout margins.
     */
    open var layoutFrame: CGRect {
        return CGRect.init(x: layoutMargins.left, y: layoutMargins.top, width: layoutWidth, height: layoutHeight)
    }
    
    /**
     Shared Files: Set view equal frame to superview frame via frames.
     
     - warning:
     If view not have superview, nothing happen.
     */
    open func setEqualSuperviewBounds() {
        guard let superview = self.superview else { return }
        frame = superview.bounds
    }
    
    /**
     Shared Files: Set view equal frame to superview frame via `autoresizingMask`.
     
     - warning:
     If view not have superview, nothing happen.
     */
    open func setEqualSuperviewBoundsWithAutoresizingMask() {
        guard let superview = self.superview else { return }
        frame = superview.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    /**
     Shared Files: Set view equal frame to superview frame via Auto Layout.
     
     - warning:
     If view not have superview, constraints will not be added.
     */
    open func setEqualSuperviewBoundsWithAutoLayout() {
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    
    /**
     Shared Files: Set view equal frame to superview frame exlude margins via Auto Layout.
     
     - warning:
     If view not have superview, constraints will not be added.
     */
    open func setEqualSuperviewMarginsWithAutoLayout() {
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor),
            leftAnchor.constraint(equalTo: superview.layoutMarginsGuide.leftAnchor),
            rightAnchor.constraint(equalTo: superview.layoutMarginsGuide.rightAnchor),
            bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Appearance
    
    /**
     Shared Files: Wrapper for layer property `masksToBounds`.
     */
    open var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    /**
     Shared Files: Correct rounded corners by current frame.
     
     - important:
     Need call after changed frame. Better leave it in `layoutSubviews` method.
     
     - parameter corners: Case of `UIRectCorner`
     - parameter radius: Amount of radius.
     */
    open func roundCorners(_ corners: UIRectCorner = .allCorners, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    /**
     Shared Files: Rounded corners to maximum of corner radius.
     
     - important:
     Need call after changed frame. Better leave it in `layoutSubviews` method.
     */
    open func roundCorners() {
        layer.cornerRadius = min(frame.width, frame.height) / 2
    }
    
    func makeRoundCorners(_ corners: UIRectCorner = .allCorners, radius: CGFloat, superelliptic: Bool = false) {
        if superelliptic {
            let maskPath = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            layer.mask = shape
        } else {
            layer.cornerRadius = radius
            layer.masksToBounds = true
        }
    }
    
    /**
     Shared Files: Wrapper for layer property `borderColor`.
     */
    open var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            // Fix React-Native conflict issue
            guard String(describing: type(of: color)) != "__NSCFType" else { return }
            layer.borderColor = color.cgColor
        }
    }
    
    /**
     Shared Files: Wrapper for layer property `borderWidth`.
     */
    open var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /**
     Shared Files: Add shadow.
     
     - parameter color: Color of shadow.
     - parameter radius: Blur radius of shadow.
     - parameter offset: Vertical and horizontal offset from center fro shadow.
     - parameter opacity: Alpha for shadow view.
     */
    open func addShadow(ofColor color: UIColor, radius: CGFloat, offset: CGSize, opacity: Float) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        clipsToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    /**
     Shared Files: Add paralax. Depended by angle of device.
     Can be not work is user reduce motion on settins device.
     
     - parameter amount: Amount of paralax effect.
     */
    open func addParalax(amount: CGFloat) {
        motionEffects.removeAll()
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        self.addMotionEffect(group)
    }
    
    /**
     Shared Files: Remove paralax.
     */
    open func removeParalax() {
        motionEffects.removeAll()
    }
    
    // MARK: - Animations
    
    /**
     Shared Files: Appear view with fade in animation.
     
     - parameter duration: Duration of animation.
     - parameter completion: Completion when animation ended.
     */
    open func fadeIn(duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: .zero, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.alpha = 1
        }, completion: completion)
    }
    
    /**
     Shared Files: Hide view with fade out animation.
     
     - parameter duration: Duration of animation.
     - parameter completion: Completion when animation ended.
     */
    open func fadeOut(duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: .zero, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.alpha = 0
        }, completion: completion)
    }
}
#endif

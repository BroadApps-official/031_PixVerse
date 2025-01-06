import UIKit

extension UIFont {
    struct CustomFont {
        static let largeTitleRegular = UIFont.italicSystemFont(ofSize: 34)
        static let largeTitleEmphasized: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 34, weight: .black).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 34)
        }()
        
        static let title1Emphasized: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 28, weight: .black).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 28)
        }()
        
        static let title2Emphasized: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 22, weight: .black).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 22)
        }()
        
        static let title3Emphasized: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 20, weight: .black).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 20)
        }()
        
        static let headlineRegular: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 17)
        }()
        
        static let bodyEmphasized = UIFont.systemFont(ofSize: 17, weight: .semibold)        
        
        static let calloutEmphasized = UIFont.systemFont(ofSize: 16, weight: .semibold)        
        
        static let subheadlineEmphasized = UIFont.systemFont(ofSize: 15, weight: .semibold)     
        static let subheadlineEmphasizedItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 15, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 15)
        }()

        static let footnoteEmphasized = UIFont.systemFont(ofSize: 13, weight: .semibold)
        static let footnoteEmphasizedItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 13, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 13)
        }()
        
        static let caption1Emphasized = UIFont.systemFont(ofSize: 12, weight: .medium)
        static let caption2Emphasized = UIFont.systemFont(ofSize: 11, weight: .semibold)
        
        static let largeTitle = UIFont.systemFont(ofSize: 34)
        static let largeTitleBold = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        static let title1Regular = UIFont.systemFont(ofSize: 28)
        static let title1Bold = UIFont.systemFont(ofSize: 28, weight: .bold)
        
        static let title2Regular = UIFont.systemFont(ofSize: 22)
        static let title2Bold = UIFont.systemFont(ofSize: 22, weight: .bold)
        
        static let title3Regular = UIFont.systemFont(ofSize: 20)
        static let title3Semobold = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        static let headline = UIFont.systemFont(ofSize: 27, weight: .semibold)
        static let headlineItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 17)
        }()
        
        static let bodyRegular = UIFont.systemFont(ofSize: 17)
        static let bodySemibold = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let bodyItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .regular).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 17)
        }()
        static let bodySemiboldItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 17)
        }()
        
        static let calloutRegular = UIFont.systemFont(ofSize: 16)
        static let calloutSemibold = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let calloutItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 16, weight: .regular).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 16)
        }()
        static let calloutSemiboldItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 16, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 16)
        }()
        
        static let subheadlineRegular = UIFont.systemFont(ofSize: 15)
        static let subheadlineSemibold = UIFont.systemFont(ofSize: 15, weight: .semibold)
        static let subheadlineItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 15, weight: .regular).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 15)
        }()
        static let subheadlineSemiboldItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 15, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 15)
        }()
        
        static let footnoteRegular = UIFont.systemFont(ofSize: 13)
        static let footnoteSemibold = UIFont.systemFont(ofSize: 13, weight: .semibold)
        static let footnoteItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 13, weight: .regular).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 13)
        }()
        static let footnoteSemiboldItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 13, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 13)
        }()
        
        static let caption1Regular = UIFont.systemFont(ofSize: 12)
        static let caption1Medium = UIFont.systemFont(ofSize: 12, weight: .medium)
        static let caption1Italic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 12, weight: .regular).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 12)
        }()
        static let caption1SemiboldItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 12, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 12)
        }()
        
        static let caption2Regular = UIFont.systemFont(ofSize: 11)
        static let caption2Semibold = UIFont.systemFont(ofSize: 11, weight: .semibold)
        static let caption2Italic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 11, weight: .regular).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 11)
        }()
        static let caption2SemiboldItalic: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 11, weight: .semibold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 11)
        }()
        
        static let onbFont: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 28, weight: .bold).fontDescriptor
                .withSymbolicTraits([.traitBold, .traitItalic])
            return UIFont(descriptor: descriptor ?? UIFontDescriptor(), size: 28)
        }()
    }
}

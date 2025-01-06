import Foundation

let L = Localized()
@dynamicMemberLookup
struct Localized {
    let bundle: Bundle
    let preferredLanguages: [String]?
    let locale: Locale?
    
    init(bundle: Bundle = .main, preferredLanguages: [String]? = nil, locale: Locale? = nil) {
        self.bundle = bundle
        self.preferredLanguages = preferredLanguages
        self.locale = locale
    }
    
    func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "", comment: "")
    }
    
    subscript(dynamicMember key: String) -> String {
        return localized(key)
    }
}

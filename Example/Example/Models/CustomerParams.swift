import Foundation

struct CustomerParams: Codable {
    var culture: Culture?
    var email: String?
    var ip: String?
    
    init(culture: Culture? = nil, email: String? = nil, ip: String? = nil) {
        self.culture = culture
        self.email = email
        self.ip = ip
    }
}

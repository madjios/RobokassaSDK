import Foundation

enum Culture: String, Codable {
    case eng
    case ru
    
    var iso: String { rawValue }
}

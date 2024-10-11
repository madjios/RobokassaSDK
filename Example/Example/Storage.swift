import Foundation

final class Storage {
    private let userDefaults = UserDefaults.standard
    
    var previoudOrderId: Int? {
        get {
            userDefaults.object(forKey: Keys.previousOrderId.key) as? Int
        } set {
            userDefaults.set(newValue, forKey: Keys.previousOrderId.key)
        }
    }
}

fileprivate extension Storage {
    enum Keys: String {
        case previousOrderId = "app.prev.order.id"
        
        var key: String { rawValue }
    }
}

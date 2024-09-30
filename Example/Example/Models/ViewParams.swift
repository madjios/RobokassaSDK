import Foundation
import UIKit

struct ViewParams: Codable {
    
    /// Цвет фона тулбара на странице оплаты.
    /// Указывается в формате Color Hex, например, #000000 для черного цвета.
    var toolbarBgColor: String?
    
    /// Цвет текста тулбара на странице оплаты.
    /// Указывается в формате Color Hex, например, #cccccc для серого цвета.
    var toolbarTextColor: String?
    
    /// Значение заголовка в тулбаре на странице оплаты. Максимальная длина — 30 символов.
    var toolbarText: String?
    
    /// Этот параметр показывает, отображать или нет тулбар на странице оплаты.
    var hasToolbar: Bool = true
    
    init(toolbarBgColor: String? = nil, toolbarTextColor: String? = nil, toolbarText: String? = nil, hasToolbar: Bool) {
        self.toolbarBgColor = toolbarBgColor
        self.toolbarTextColor = toolbarTextColor
        self.toolbarText = toolbarText
        self.hasToolbar = hasToolbar
    }
    
    private func isValidColorHex(_ hex: String?) -> Bool {
        guard let hex = hex else { return false }
        var rgb: UInt64 = 0
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        return scanner.scanHexInt64(&rgb)
    }
}

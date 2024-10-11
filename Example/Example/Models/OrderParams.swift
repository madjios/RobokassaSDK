import Foundation

struct OrderParams: Codable {
    var invoiceId: Int = -1
    var previousInvoiceId: Int = -1
    var orderSum: Double = 0.0
    var description: String? = nil
    var incCurrLabel: String? = nil
    var token: String? = nil
    var isRecurrent: Bool = false
    var isHold: Bool = false
    var outSumCurrency: Currency? = nil
    var expirationDate: Date? = nil
    var receipt: Receipt? = nil
}

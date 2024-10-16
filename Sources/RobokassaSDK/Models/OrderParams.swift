import Foundation

public struct OrderParams: Codable {
    public var invoiceId: Int = -1
    public var previousInvoiceId: Int = -1
    public var orderSum: Double = 0.0
    public var description: String? = nil
    public var incCurrLabel: String? = nil
    public var token: String? = nil
    public var isRecurrent: Bool = false
    public var isHold: Bool = false
    public var outSumCurrency: Currency? = nil
    public var expirationDate: Date? = nil
    public var receipt: Receipt? = nil
}

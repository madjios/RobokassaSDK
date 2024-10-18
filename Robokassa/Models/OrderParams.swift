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
    
    public init(
        invoiceId: Int,
        previousInvoiceId: Int,
        orderSum: Double,
        description: String? = nil,
        incCurrLabel: String? = nil,
        token: String? = nil,
        isRecurrent: Bool,
        isHold: Bool,
        outSumCurrency: Currency? = nil,
        expirationDate: Date? = nil,
        receipt: Receipt? = nil
    ) {
        self.invoiceId = invoiceId
        self.previousInvoiceId = previousInvoiceId
        self.orderSum = orderSum
        self.description = description
        self.incCurrLabel = incCurrLabel
        self.token = token
        self.isRecurrent = isRecurrent
        self.isHold = isHold
        self.outSumCurrency = outSumCurrency
        self.expirationDate = expirationDate
        self.receipt = receipt
    }
}

import Foundation

enum Endpoint {
    case getInvoice(PaymentParams, Bool)
    case confirmHoldPayment(PaymentParams)
    case cancelHoldPayment(PaymentParams)
    case reccurentPayment(PaymentParams)
    case checkPaymentStatus(PaymentParams)
    
    var url: String {
        return switch self {
        case .getInvoice: Constants.URLs.main
        case .confirmHoldPayment: Constants.URLs.holdingConfirm
        case .cancelHoldPayment: Constants.URLs.holdingCancel
        case .reccurentPayment: Constants.URLs.recurringPayment
        case .checkPaymentStatus: Constants.URLs.checkPayment
        }
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var stringBody: String? {
        switch self {
        case let .getInvoice(params, isTest):
            return params.payPostParams(isTest: isTest)
        case let .confirmHoldPayment(params):
            return params.confirmHoldingParams
        case let .cancelHoldPayment(params):
            return params.cancelHoldingParams
        case let .reccurentPayment(params):
            return params.recurrentPostParams
        case let .checkPaymentStatus(params):
            return params.checkPaymentParams
        }
    }
}

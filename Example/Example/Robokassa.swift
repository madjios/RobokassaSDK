import UIKit

enum PaymentType {
    case simplePayment
    case holding
    case confirmHolding
    case cancelHolding
    case reccurentPayment
    
    var title: String {
        switch self {
        case .simplePayment: "Простая оплата"
        case .holding: "Холдирование"
        case .confirmHolding: "Подтвердить холдирование"
        case .cancelHolding: "Отменить холдирование"
        case .reccurentPayment: "Реккурентная оплата"
        }
    }
    
    func getURLPath(with invoiceID: String) -> String {
        switch self {
        case .simplePayment: Constants.URLs.simplePayment + invoiceID
        case .holding: Constants.URLs.simplePayment + invoiceID
        case .confirmHolding: Constants.URLs.holdingConfirm + invoiceID
        case .cancelHolding: Constants.URLs.holdingCancel + invoiceID
        case .reccurentPayment: Constants.URLs.recurringPayment + invoiceID
        }
    }
}

class Robokassa {
    private(set) var login: String
    private(set) var password: String
    private(set) var password2: String
    private(set) var isTesting: Bool
    
    init(login: String, password: String, password2: String = Constants.PWD_2, isTesting: Bool = false) {
        self.login = login
        self.password = password
        self.password2 = password2
        self.isTesting = isTesting
    }
    
    func startSimplePayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        fetchInvoice(with: params, paymentType: .simplePayment)
    }
    
    func startHoldingPayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        fetchInvoice(with: params, paymentType: .holding)
    }
    
    func confirmHoldingPayment(with params: PaymentParams, completion: @escaping (Result<Void, Error>) -> Void) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        requestConfirmHoldingPayment(with: params, completion: completion)
    }
    
    func confirmHoldingPayment(with params: PaymentParams) async throws {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        
        try await requestConfirmHoldingPayment(with: params)
    }
    
    func cancelHoldingPayment(with params: PaymentParams, completion: @escaping (Result<Void, Error>) -> Void) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        requestHoldingPaymentCancellation(with: params, completion: completion)
    }
    
    func cancelHoldingPayment(with params: PaymentParams) async throws {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        try await requestHoldingPaymentCancellation(with: params)
    }
    
    func startReccurentPayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isRecurrent = true
        fetchInvoice(with: params, paymentType: .reccurentPayment)
    }
}

// MARK: - Privates -

fileprivate extension Robokassa {
    func fetchInvoice(with params: PaymentParams, paymentType: PaymentType) {
        Task { @MainActor in
            do {
                let result = try await RequestManager.shared.request(to: .getInvoice(params, isTesting), type: Invoice.self)
                pushWebView(with: result.invoiceID, paymentType: paymentType)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func requestConfirmHoldingPayment(with params: PaymentParams, completion: @escaping (Result<Void, Error>) -> Void) {
        Task { @MainActor in
            do {
                let _esult = try await RequestManager.shared.request(
                    to: .confirmHoldPayment(params, isTesting),
                    type: Bool.self
                )
                completion(.success(()))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func requestConfirmHoldingPayment(with params: PaymentParams) async throws {
        Task { @MainActor in
            do {
                return try await RequestManager.shared.request(
                    to: .confirmHoldPayment(params, isTesting),
                    type: Bool.self
                )
            } catch {
                print(error.localizedDescription)
                throw error
            }
        }
    }
    
    func requestHoldingPaymentCancellation(with params: PaymentParams, completion: @escaping (Result<Void, Error>) -> Void) {
        Task { @MainActor in
            do {
                let _ = try await RequestManager.shared.request(
                    to: .cancelHoldPayment(params, isTesting), 
                    type: Bool.self
                )
                completion(.success(()))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func requestHoldingPaymentCancellation(with params: PaymentParams) async throws {
        Task { @MainActor in
            do {
                return try await RequestManager.shared.request(
                    to: .cancelHoldPayment(params, isTesting),
                    type: Bool.self
                )
            } catch {
                print(error.localizedDescription)
                throw error
            }
        }
    }
    
    func pushWebView(with invoiceId: String, paymentType: PaymentType) {
        let webView = WebViewController(invoiceId: invoiceId, paymentType: paymentType, isTesting: isTesting)
        
        if UIApplication.shared.topViewController()?.navigationController == nil {
            let navController = UINavigationController(rootViewController: webView)
            webView.modalTransitionStyle = .crossDissolve
            webView.modalPresentationStyle = .overFullScreen
            webView.isModalInPresentation = true
            UIApplication.shared.topViewController()?.present(navController, animated: true)
        } else {
            UIApplication.shared.topViewController()?.navigationController?.pushViewController(webView, animated: true)
        }
    }
}

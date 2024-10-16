import UIKit

public enum PaymentType {
    case simplePayment
    case holding
    case confirmHolding
    case cancelHolding
    case reccurentPayment
    
    public var title: String {
        switch self {
        case .simplePayment: "Простая оплата"
        case .holding: "Холдирование"
        case .confirmHolding: "Подтвердить холдирование"
        case .cancelHolding: "Отменить холдирование"
        case .reccurentPayment: "Реккурентная оплата"
        }
    }
}

public final class Robokassa {
    private(set) var invoiceId: String
    private(set) var login: String
    private(set) var password: String
    private(set) var password2: String
    private(set) var isTesting: Bool
    
    public init(invoiceId: String, login: String, password: String, password2: String, isTesting: Bool = false) {
        self.invoiceId = invoiceId
        self.login = login
        self.password = password
        self.password2 = password2
        self.isTesting = isTesting
    }
    
    public func startSimplePayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        fetchInvoice(with: params, paymentType: .simplePayment)
    }
    
    public func startHoldingPayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        fetchInvoice(with: params, paymentType: .holding)
    }
    
    public func confirmHoldingPayment(with params: PaymentParams, completion: @escaping (Result<Bool, Error>) -> Void) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        requestConfirmHoldingPayment(with: params, completion: completion)
    }
    
    public func confirmHoldingPayment(with params: PaymentParams) async throws -> Bool {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        
        return try await requestConfirmHoldingPayment(with: params)
    }
    
    public func cancelHoldingPayment(with params: PaymentParams, completion: @escaping (Result<Bool, Error>) -> Void) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        requestHoldingPaymentCancellation(with: params, completion: completion)
    }
    
    public func cancelHoldingPayment(with params: PaymentParams) async throws -> Bool {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        
        return try await requestHoldingPaymentCancellation(with: params)
    }
    
    public func startDefaultReccurentPayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isRecurrent = true
        fetchInvoice(with: params, paymentType: .reccurentPayment)
    }
    
    public func startReccurentPayment(with params: PaymentParams, completion: @escaping (Result<Bool, Error>) -> Void) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isRecurrent = true
        requestRecurrentPayment(with: params, completion: completion)
    }
    
    public func startReccurentPayment(with params: PaymentParams) async throws -> Bool {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isRecurrent = true
        
        return try await requestRecurrentPayment(with: params)
    }
}

// MARK: - Privates -

fileprivate extension Robokassa {
    func fetchInvoice(with params: PaymentParams, paymentType: PaymentType) {
        Task { @MainActor in
            do {
                let result = try await RequestManager.shared.request(to: .getInvoice(params, isTesting), type: Invoice.self)
                pushWebView(with: result.invoiceID, params: params, paymentType: paymentType)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func requestConfirmHoldingPayment(with params: PaymentParams, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task { @MainActor in
            do {
                let response = try await RequestManager.shared.request(to: .confirmHoldPayment(params), type: String.self)
                let result = response.lowercased().contains("true")
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func requestConfirmHoldingPayment(with params: PaymentParams) async throws -> Bool {
        let response = try await RequestManager.shared.request(to: .confirmHoldPayment(params), type: String.self)
        return response.lowercased().contains("true")
    }
    
    func requestHoldingPaymentCancellation(with params: PaymentParams, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task { @MainActor in
            do {
                let response = try await RequestManager.shared.request(to: .cancelHoldPayment(params), type: String.self)
                let result = response.lowercased().contains("true")
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func requestHoldingPaymentCancellation(with params: PaymentParams) async throws -> Bool {
        let response = try await RequestManager.shared.request(to: .cancelHoldPayment(params), type: String.self)
        return response.lowercased().contains("true")
    }
    
    func requestRecurrentPayment(with params: PaymentParams, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task { @MainActor in
            do {
                let response = try await RequestManager.shared.request(to: .reccurentPayment(params), type: String.self)
                let result = response.lowercased().contains("ok")
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func requestRecurrentPayment(with params: PaymentParams) async throws -> Bool {
        let response = try await RequestManager.shared.request(to: .reccurentPayment(params), type: String.self)
        return response.lowercased().contains("ok")
    }
    
    func pushWebView(with invoiceId: String, params: PaymentParams, paymentType: PaymentType) {
        let webView = WebViewController(
            invoiceId: invoiceId,
            params: params,
            paymentType: paymentType,
            isTesting: isTesting
        )
        
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

import UIKit

enum PaymentType {
    case simplePayment
    case holding
    case reccurentPayment
    
    var title: String {
        switch self {
        case .simplePayment: "Простая оплата"
        case .holding: "Холдирование"
        case .reccurentPayment: "Реккурентная оплата"
        }
    }
}

class Robokassa {
    private(set) var login: String
    private(set) var password: String
    private(set) var password2: String
    private(set) var isTesting: Bool
    
    init(login: String, password: String, isTesting: Bool = false) {
        self.login = login
        self.password = password
        self.password2 = Constants.PWD_2
        self.isTesting = isTesting
    }
    
    func startSimplePayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        
        pushWebView(with: params, urlPath: Constants.URLs.main)
    }
    
    func startHoldingPayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isHold = true
        
        pushWebView(with: params, urlPath: Constants.URLs.main)
    }
    
    func startReccurentPayment(with params: PaymentParams) {
        var params = params
        params.merchantLogin = login
        params.password1 = password
        params.password2 = password2
        params.order.isRecurrent = true
        
        pushWebView(with: params, urlPath: Constants.URLs.main)
    }
}

// MARK: - Privates -

fileprivate extension Robokassa {
    func pushWebView(with params: PaymentParams, urlPath: String) {
        let webView = WebViewController(params: params, method: .post, urlPath: urlPath, isTesting: isTesting)
        
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

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // MARK: - Properties -
    
    private var webView: WKWebView!
    private var timer: Timer?
    
    private var isPaymentSuccessfullyFinished = false
    private var seconds = 60
    
    private(set) var invoiceId: String
    private(set) var params: PaymentParams
    private(set) var paymentType: PaymentType
    private(set) var isTesting: Bool
    
    var onSucccessHandler: (() -> Void)?
    var onFailureHandler: ((String) -> Void)?
    var onDismissHandler: (() -> Void)?
    
    // MARK: - Init -
    
    init(invoiceId: String, params: PaymentParams, paymentType: PaymentType, isTesting: Bool = false) {
        self.invoiceId = invoiceId
        self.params = params
        self.paymentType = paymentType
        self.isTesting = isTesting
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        configureWebSettings()
        configureBackButton()
        embedSubviews()
        setSubviewsConstraints()
        loadWebView()
    }

}

// MARK: - WebView Delegate -

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Выполняем JavaScript для получения текста ответа
        let script = "document.body.innerText;"
        webView.evaluateJavaScript(script) { (result, error) in
            if let error = error {
                print("Ошибка при выполнении скрипта: \(error)")
                return
            }
            if let result, let json = result as? String, let jsonData = json.data(using: .utf8) {
                do {
                    if let object = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
                        let stringData = String(data: data, encoding: .utf8) ?? ""
                        print(stringData)
//                        let mappedObject = try JSONDecoder().decode(Invoce.self, from: data)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("Invalid response format")
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
           /*
            Проверка должна быть такой:
            - если УРЛ начинается с https://auth.robokassa.ru/Merchant/State/
            - ИЛИ содержит в себе "ipol.tech/"
            - ИЛИ содержит в себе "ipol.ru/"
            тогда мы считаем что платеж завершен.
            */
            if url.absoluteString.starts(with: "https://auth.robokassa.ru/Merchant/State/") ||
                url.absoluteString.contains("ipol.tech/") ||
                url.absoluteString.contains("ipol.ru/") {
                checkPaymentState()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    if !self.isPaymentSuccessfullyFinished {
                        self.startTimer()
                    }
                }
            }
        }
        decisionHandler(.allow)
    }
}

// MARK: - Privates -

fileprivate extension WebViewController {
    func configureWebSettings() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.httpCookieStore.setCookie(HTTPCookie(properties: [
            .domain: "https://auth.robokassa.ru",
            .path: "/",
            .name: "cookie_name",
            .value: "cookie_value",
            .secure: true
        ])!)
        
        let webConfig = webView.configuration
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfig.websiteDataStore = .default()
        
        if let url = Bundle.main.url(forResource: "file", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    func loadWebView() {
        if let url = URL(string: Constants.URLs.simplePayment + "\(params.order.invoiceId)") {
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            webView.load(request)
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, !isPaymentSuccessfullyFinished else {
                self?.invalidateTimer()
                return
            }
            
            if self.seconds > 0 {
                self.seconds -= 1
                
                if self.seconds % 2 == 0 {
                    checkPaymentState()
                }
            } else {
                invalidateTimer()
            }
        }
    }
    
    func checkPaymentState() {
        Task { @MainActor in
            do {
                let result = try await RequestManager.shared.request(to: .checkPaymentStatus(params), type: PaymentStatusResponse.self)
                
                switch paymentType {
                case .simplePayment, .confirmHolding, .reccurentPayment, .cancelHolding:
                    if result.stateCode == .paymentSuccess {
                        isPaymentSuccessfullyFinished = true
                        onSucccessHandler?()
                        didTapBack()
                    } else {
                        onFailureHandler?("Payment state code: \(result.stateCode)" + result.stateCode.title)
                    }
                case .holding:
                    if result.stateCode == .holdSuccess {
                        isPaymentSuccessfullyFinished = true
                        onSucccessHandler?()
                        didTapBack()
                    } else {
                        onFailureHandler?("Payment state code: \(result.stateCode)" + result.stateCode.title)
                    }
                }
            } catch {
                invalidateTimer()
                isPaymentSuccessfullyFinished = true
                onFailureHandler?(error.localizedDescription)
                print("In " + #filePath + ", method " + #function + "Catched an error: \(error.localizedDescription)")
            }
        }
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Privates -

fileprivate extension WebViewController {
    func configureBackButton() {
        navigationItem.leftBarButtonItem = .init(
            image: .init(systemName: "chevron.left"), 
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
    }
    
    @objc func didTapBack() {
        if (navigationController?.viewControllers ?? []).count == 1 {
            navigationController?.dismiss(animated: true) { [weak self] in
                self?.onDismissHandler?()
            }
        } else {
            navigationController?.popViewController(animated: true)
            DispatchQueue.main.async {
                self.onDismissHandler?()
            }
        }
    }
}

// MARK: - Setup subviews -

fileprivate extension WebViewController {
    func embedSubviews() {
        view.addSubview(webView)
    }
    
    func setSubviewsConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

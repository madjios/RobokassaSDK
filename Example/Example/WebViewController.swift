import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // MARK: - Properties -
    
    private var webView: WKWebView!
    
    private(set) var invoiceId: String
    private(set) var paymentType: PaymentType
    private(set) var isTesting: Bool
    
    var onDismissHandler: (() -> Void)?
    
    // MARK: - Init -
    
    init(invoiceId: String, paymentType: PaymentType, isTesting: Bool = false) {
        self.invoiceId = invoiceId
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
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        config.userContentController = contentController
        
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
}

// MARK: - WebView Script Message Handler -

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler", let messageBody = message.body as? String {
            print("Received message: \(messageBody)")
        }
    }
}

/*
 paymentStatus: success
 */

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
        
        let webView = WKWebView()
        let webConfig = webView.configuration
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfig.websiteDataStore = .default()
        
        if let url = Bundle.main.url(forResource: "file", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    func loadWebView() {
        if let url = URL(string: Constants.URLs.simplePayment + invoiceId) {
//            let script = """
//                    fetch('\(Constants.URLs.main)', {
//                        method: 'POST',
//                        headers: {
//                            'Content-Type': 'application/x-www-form-urlencoded'
//                        },
//                        body: '\(urlParams)'
//                    })
//                    .then(response => response.json())
//                    .then(data => console.log(data))
//                    .catch(error => console.error('Error:', error));
//                    """
//            
//            // Выполнение скрипта после загрузки страницы
//            webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
//            webView.evaluateJavaScript(script, completionHandler: nil)
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
//            if let postData = urlParams.data(using: .utf8) {
//                let query = String(data: postData, encoding: .utf8) ?? ""
//                
//                var urlComponent = URLComponents(string: Constants.URLs.main)
//                urlComponent?.query = query
//                
//                request.url = urlComponent?.url
//                request.httpBody = postData
//            }
            
            webView.load(request)
        }
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

import UIKit
import RobokassaSDK

final class ViewController: UIViewController {
    
    // MARK: - Lifecycle -
    
    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 8.0
        
        return stack
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "ic-logo")
        
        return imageView
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.borderStyle = .roundedRect
        textField.placeholder = "Введите..."
        
        return textField
    }()
    
    private let simplePaymentButton: Button = {
        let button = Button()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(RobokassaSDK.PaymentType.simplePayment.title, for: .normal)
        
        return button
    }()
    
    private let holdingButton: Button = {
        let button = Button()
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle(PaymentType.holding.title, for: .normal)
        
        return button
    }()
    
    private let confirmHoldingButton: Button = {
        let button = Button()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(RobokassaSDK.PaymentType.confirmHolding.title, for: .normal)
        
        return button
    }()
    
    private let cancelHoldingButton: Button = {
        let button = Button()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(RobokassaSDK.PaymentType.cancelHolding.title, for: .normal)
        
        return button
    }()
    
    private let reccurentPaymentButton: Button = {
        let button = Button()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(RobokassaSDK.PaymentType.reccurentPayment.title, for: .normal)
        
        return button
    }()
    
    private let storage = Storage()
    
    private let buttonHeight: CGFloat = 48.0
    
    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = imageView
        view.backgroundColor = .secondarySystemBackground
        setupActions()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        simplePaymentButton.isLoading = false
        holdingButton.isLoading = false
        reccurentPaymentButton.isLoading = false
    }

}

// MARK: - Actions -

fileprivate extension ViewController {
    func setupActions() {
        textField.addAction(.init(handler: { action in
            if let text = (action.sender as? UITextField)?.text {
                print(text)
            }
        }), for: .editingChanged)
        
        simplePaymentButton.addAction(.init(handler: { [weak self] _ in
            self?.simplePaymentButton.isLoading = true
//            self?.routeToWebView(with: .simplePayment)
        }), for: .touchUpInside)
        
        holdingButton.addAction(.init(handler: { [weak self] _ in
            self?.holdingButton.isLoading = true
//            self?.routeToWebView(with: .holding)
        }), for: .touchUpInside)
        
        confirmHoldingButton.addAction(.init(handler: { [weak self] _ in
            self?.confirmHoldingButton.isLoading = true
            self?.didTapConfirmHolding()
        }), for: .touchUpInside)
        
        cancelHoldingButton.addAction(.init(handler: { [weak self] _ in
            self?.cancelHoldingButton.isLoading = true
            self?.didTapCancelHolding()
        }), for: .touchUpInside)
        
        reccurentPaymentButton.addAction(.init(handler: { [weak self] _ in
            self?.didTapRecurrent()
        }), for: .touchUpInside)
    }
    
    func routeToWebView(with type: RobokassaSDK.PaymentType) {
//        switch type {
//        case .simplePayment:
//            createRobokassa().startSimplePayment(with: createParams())
//        case .holding:
//            createRobokassa().startHoldingPayment(with: createParams())
//        case .reccurentPayment:
//            createRobokassa().startDefaultReccurentPayment(with: createParams())
//        default:
//            break
//        }
    }
}

// MARK: - Privates -

fileprivate extension ViewController {
    func didTapConfirmHolding() {
//        createRobokassa()
//            .confirmHoldingPayment(with: createParams()) { [weak self] result in
//                self?.confirmHoldingButton.isLoading = false
//                
//                switch result {
//                case let .success(response):
//                    print("SUCCESSFULLY CONFIRMED HOLDING PAYMENT. Response: \(response)")
//                case let .failure(error):
//                    print(error.localizedDescription)
//                }
//            }
    }
    
    func didTapCancelHolding() {
//        createRobokassa()
//            .cancelHoldingPayment(with: createParams()) { [weak self] result in
//                self?.cancelHoldingButton.isLoading = false
//                
//                switch result {
//                case let .success(response):
//                    print("SUCCESSFULLY CANCELLED HOLDING PAYMENT. Response: \(response)")
//                case let .failure(error):
//                    print(error.localizedDescription)
//                }
//            }
    }
    
    func didTapRecurrent() {
//        if let previousOrderId = storage.previoudOrderId {
//            var params = createParams()
//            params.order.previousInvoiceId = previousOrderId
//            createRobokassa().startReccurentPayment(with: params) { result in
//                switch result {
//                case let .success(response):
//                    print("SUCCESSFULLY FINISHED RECURRENT PAYMENT. Response: \(response)")
//                case let .failure(error):
//                    print(error.localizedDescription)
//                }
//            }
//        } else {
//            routeToWebView(with: .reccurentPayment)
//        }
    }
    
//    func createRobokassa() -> RobokassaSDK.Robokassa {
//        Robokassa(
//            invoiceId: textField.text ?? "",
//            login: "ipolh.com",
//            password: "X7SlyJ9I4z50JpaiKCjj",
//            password2: Constants.PWD_2,
//            isTesting: false
//        )
//    }
    
//    func createParams() -> PaymentParams {
//        PaymentParams(
//            order: .init(
//                invoiceId: Int(textField.text ?? "") ?? 0,
//                orderSum: 1.0,
//                description: "Test simple pay",
//                expirationDate: Date().dateByAdding(.day, value: 1),
//                receipt: .init(
//                    items: [
//                        .init(
//                            name: "Ботинки детские",
//                            sum: 1.0,
//                            quantity: 1,
//                            paymentMethod: .fullPayment,
//                            tax: .NONE
//                        )
//                    ]
//                )
//            ),
//            customer: .init(culture: .ru, email: "iammadj.u@gmail.com"),
//            view: .init(toolbarText: "Простая оплата", hasToolbar: true)
//        )
//    }
}

// MARK: - Setup subviews -

fileprivate extension ViewController {
    func setupSubviews() {
        embedSubviews()
        setSubviewsConstraints()
    }
    
    func embedSubviews() {
        view.addSubview(vStack)
        
        vStack.addArrangedSubview(textField)
        vStack.addArrangedSubview(simplePaymentButton)
        vStack.addArrangedSubview(holdingButton)
        vStack.addArrangedSubview(confirmHoldingButton)
        vStack.addArrangedSubview(cancelHoldingButton)
        vStack.addArrangedSubview(reccurentPaymentButton)
        vStack.setCustomSpacing(32.0, after: textField)
    }
    
    func setSubviewsConstraints() {
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.0),
            vStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0),
            vStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0),
            vStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0)
        ])
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: buttonHeight),
            simplePaymentButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            holdingButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            reccurentPaymentButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
    }
}

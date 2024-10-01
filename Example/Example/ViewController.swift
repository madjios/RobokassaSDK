import UIKit

class ViewController: UIViewController {
    
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
    
    private let simplePaymentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PaymentType.simplePayment.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 16.0
        
        return button
    }()
    
    private let holdingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PaymentType.holding.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 16.0
        
        return button
    }()
    
    private let confirmHoldingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PaymentType.confirmHolding.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 16.0
        
        return button
    }()
    
    private let cancelHoldingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PaymentType.cancelHolding.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 16.0
        
        return button
    }()
    
    private let reccurentPaymentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PaymentType.reccurentPayment.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 16.0
        
        return button
    }()
    
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 16.0
        
        return stack
    }()
    
    private let recurrentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray2
        label.text = "Есть реккурентный платеж"
        
        return label
    }()
    
    private let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        
        return switcher
    }()
    
    private let buttonHeight: CGFloat = 48.0
    
    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = imageView
        view.backgroundColor = .secondarySystemBackground
        setupActions()
        setupSubviews()
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
            self?.routeToWebView(with: .simplePayment)
        }), for: .touchUpInside)
        
        holdingButton.addAction(.init(handler: { [weak self] _ in
            self?.routeToWebView(with: .holding)
        }), for: .touchUpInside)
        
        confirmHoldingButton.addAction(.init(handler: { [weak self] _ in
            self?.didTapConfirmHolding()
        }), for: .touchUpInside)
        
        cancelHoldingButton.addAction(.init(handler: { [weak self] _ in
            self?.didTapCancelHolding()
        }), for: .touchUpInside)
        
        reccurentPaymentButton.addAction(.init(handler: { [weak self] _ in
            self?.didTapRecurrent()
        }), for: .touchUpInside)
    }
    
    func routeToWebView(with type: PaymentType) {
        let paymentParams = createParams()
        let robokassa = createRobokassa()
        
        switch type {
        case .simplePayment:
            robokassa.startSimplePayment(with: paymentParams)
        case .holding:
            robokassa.startHoldingPayment(with: paymentParams)
        case .reccurentPayment:
            robokassa.startReccurentPayment(with: paymentParams)
        default:
            break
        }
    }
}

// MARK: - Privates -

fileprivate extension ViewController {
    func didTapConfirmHolding() {
        createRobokassa()
            .confirmHoldingPayment(with: createParams()) { result in
                switch result {
                case .success:
                    print("SUCCESSFULLY CONFIRMED HOLDING PAYMENT")
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
    }
    
    func didTapCancelHolding() {
        createRobokassa()
            .cancelHoldingPayment(with: createParams()) { result in
                switch result {
                case .success:
                    print("SUCCESSFULLY CANCELLED HOLDING PAYMENT")
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
    }
    
    func didTapRecurrent() {
        if switcher.isOn {
            
        } else {
            routeToWebView(with: .reccurentPayment)
        }
    }
    
    func createRobokassa() -> Robokassa {
        Robokassa(
            login: Constants.MERCHANT,
            password: Constants.PWD_1,
            isTesting: false
        )
    }
    
    func createParams() -> PaymentParams {
        PaymentParams(
            order: .init(
                invoiceId: Int(textField.text ?? "") ?? 0,
                orderSum: 1.0,
                description: "Test simple pay",
                expirationDate: Date().dateByAdding(.day, value: 1),
                receipt: .init(
                    items: [
                        .init(
                            name: "Ботинки детские",
                            sum: 1.0,
                            quantity: 1,
                            paymentMethod: .fullPayment,
                            tax: .NONE
                        )
                    ]
                )
            ),
            customer: .init(culture: .ru, email: "p.kolosov@list.ru"),
            view: .init(toolbarText: "Простая оплата", hasToolbar: true)
        )
    }
}

// MARK: - Setup subviews -

fileprivate extension ViewController {
    func setupSubviews() {
        embedSubviews()
        setSubviewsConstraints()
    }
    
    func embedSubviews() {
        view.addSubview(vStack)
        view.addSubview(hStack)
        
        vStack.addArrangedSubview(textField)
        vStack.addArrangedSubview(simplePaymentButton)
        vStack.addArrangedSubview(holdingButton)
        vStack.addArrangedSubview(confirmHoldingButton)
        vStack.addArrangedSubview(cancelHoldingButton)
        vStack.addArrangedSubview(reccurentPaymentButton)
        vStack.setCustomSpacing(32.0, after: textField)
        
        hStack.addArrangedSubview(recurrentLabel)
        hStack.addArrangedSubview(switcher)
    }
    
    func setSubviewsConstraints() {
        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.0),
            vStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0),
            vStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0)
        ])
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: buttonHeight),
            simplePaymentButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            holdingButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            reccurentPaymentButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 16.0),
            hStack.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 16.0),
            hStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
            hStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0)
        ])
    }
}

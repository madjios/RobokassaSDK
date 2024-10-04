import Foundation

enum Constants {
    static let EXTRA_ERROR = "com.robokassa.PAY_ERROR"
    static let EXTRA_PARAMS = "com.robokassa.PAYMENT_PARAMS"
    static let EXTRA_INVOICE_ID = "com.robokassa.PAYMENT_INVOICE_ID"
    static let EXTRA_TEST_PARAMETERS = "com.robokassa.TEST_PARAMETERS"
    static let EXTRA_CODE_RESULT = "com.robokassa.PAYMENT_CODE_RESULT"
    static let EXTRA_CODE_STATE = "com.robokassa.PAYMENT_CODE_STATE"
    static let EXTRA_ERROR_DESC = "com.robokassa.PAYMENT_ERROR_DESC"
    
    static let FORM_URL_ENCODED = "application/x-www-form-urlencoded"
    
    static let syncServerTimeDefault: Int64 = 2000
    static let syncServerTimeoutDefault: Int64 = 40000
    
    static let MERCHANT = "ipolh.com"
    static let PWD_1 = "X7SlyJ9I4z50JpaiKCjj"
    static let PWD_2 = "Y7t35UJPLS4IZAAan7SP"
    static let PWD_TEST_1 = "o1zCrG7EHdB6TYPkt0K5"
    static let PWD_TEST_2 = "zgxF4Vf1oAv4k3uR7rZT"
}

// MARK: - URLs -

extension Constants {
    enum URLs {
        static let main = "https://auth.robokassa.ru/Merchant/Indexjson.aspx?"
        static let simplePayment = "https://auth.robokassa.ru/Merchant/Index/"
        static let holdingConfirm = "https://auth.robokassa.ru/Merchant/Payment/Confirm"
        static let holdingCancel = "https://auth.robokassa.ru/Merchant/Payment/Cancel"
        static let recurringPayment = "https://auth.robokassa.ru/Merchant/Recurring"
        static let checkPayment = "https://auth.robokassa.ru/Merchant/WebService/Service.asmx/OpStateExt?"
    }
}

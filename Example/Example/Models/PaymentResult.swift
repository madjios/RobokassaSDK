import Foundation

struct PaymentStatusResponse: Decodable {
    let requestCode: PaymentResult?
    let stateCode: PaymentState?
    let description: String?
}

enum PaymentResult: String, Decodable {
    case checking = "-1"
    case success = "0"
    case signatureError = "1"
    case shopError = "2"
    case invoiceZeroError = "3"
    case invoiceDoubleError = "4"
    case timeoutError = "999"
    case serverError = "1000"
    
    var title: String {
        return switch self {
        case .checking:
            "Идет обработка запроса"
        case .success:
            "Запрос обработан успешно"
        case .signatureError:
            "Неверная цибровая подпись запроса"
        case .shopError:
            "Информация о магазине с таким MerchantLogin не найдена или магазин не активирован"
        case .invoiceZeroError:
            "Информация об операции с таким InvoiceID не найдена"
        case .invoiceDoubleError:
            "Найдены две операции с таким InvoiceID. Такая ошибка возникает, когда есть тестовая оплата с тем же InvoiceID"
        case .timeoutError:
            "Операция прервана по таймауту"
        case .serverError:
            "Внитренняя ошибка сервиса"
        }
    }
}

enum PaymentState: String, Decodable {
    case notInitiated = "-1"
    case initiatedNotPaid = "5"
    case cancelledNotPaid = "10"
    case holdSuccess = "20"
    case paidNotTransferred = "50"
    case paymentPayback = "60"
    case paymentStopped = "80"
    case paymentSuccess = "100"
    
    var title: String {
        return switch self {
        case .notInitiated:
            "Операция не инициализирована"
        case .initiatedNotPaid:
            "Операция только инициализирована, деньги от покупателя не получены. Или от пользователя ещё не поступила оплата по выставленному ему счёту или длатёжная система, через катееию пользователь совершает опляти, ещё не подтвердила бакт оплаты"
        case .cancelledNotPaid:
            "Операция отменена, деньеи от покупателя не былу получены. Оплата не была произведена. Покупатель отказался от оплаты или не совершил платеж, и операция отменилась по истечении времени ожидания. Либо платёж был совершен после истечения всемену ожидания. В случае возникновения спорных моментов по запросу от продавца или покупателя, операция будет перепроверена службой поддержки"
        case .holdSuccess:
            "Операция находится в статусе HOLD. Используется в случае отправки запроса на холдирование средств"
        case .paidNotTransferred:
            "Деньеи от покупателя получены, производится зачисление денег на счет магазина. Операция перешла в состояние зачисления средсте на баланс продавца. В этом статусе платёж может задержаться на некоторое время. Если платёк «висит» в этом состоянии уже долго (более 20 минит), это значит, что возникла проблема с зачислением средсте продавцу"
        case .paymentPayback:
            "Деньги после получения были возвращены покупателю. Полученные от покупателя средства возвращены на его счёт (кошелёк), с которого совершалась оплата"
        case .paymentStopped:
            "Исполнение операции приостановлено. Внештатная остановка. Произошла внештатная ситуация в процессе совершения операции (недоступны платежные интерфейсы в системе, из которой/в которую совершался платёж и т.д.). Или операция была приостановлена в системой безопасности. Операции, находящиеся в этом состоянии, разбираются нашей службой поддержки в ручном режиме"
        case .paymentSuccess:
            "Платёж проведён успешно, деньеи зачислены на баланс продавца, уведомление об успешном платеже отправлено"
        }
    }
}

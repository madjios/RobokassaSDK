# Robokassa SDK iOS

## Installation

Pod:

pod 'RobokassaSDK', :git => 'https://github.com/madjios/RobokassaSDK.git', :tag => '1.0.0'

SPM:

https://github.com/madjios/RobokassaSDK.git

### SDK позволяет интегрировать прием платежей через сервис Robokassa в мобильное приложение iOS. Библиотека написана на языке Swift.

### Требования к проекту:
Для работы Robokassa SDK необходимо: iOS версии 14.0 и выше.

### Подключение SDK:

** Общая информация **

Для работы с SDK вам понадобятся:

MerchantLogin - идентификатор (логин) магазина
Password #1 – пароль для подписи запросов к сервису
Password #2 – пароль для подписи запросов к сервису

Данные можно найти в личном кабинете (ЛК) Robokassa.
В корне репозитория собран проект состоящий из библиотеки (Robokassa.xcodeproj - для работы с Cocoapod) и демо приложения (Example) которое показывает пример интеграции SDK:
![Screenshot of a comment on a GitHub issue showing an image, added in the Markdown, of an Octocat smiling and raising a tentacle.](https://myoctocat.com/assets/images/base-octocat.svg)
Для указания Success Url и Fail Url в ЛК Робокассы вы можете использовать такие страницы заглушки:
success url
fail url
Подключение зависимостей
Для подключения библиотеки в ваш проект вы можете:
либо скачать и подключить aar файл (из app/lib). Добавьте его в папку lib вашего проекта и подключите зависимость в [build.gradle].
implementation (name: 'robokassa-library', ext: 'aar')
либо выгрузите Robokassa_Library в папку проекта и подключите библиотеку как модуль, указав в [settings.gradle] вашего проекта.
include(":Robokassa_Library")
Проведение платежей
Библиотека использует стандартную платежную форму Robokassa в виде WebView, что упрощает интеграцию и не требует реализации собственных платежных форм и серверных решений. Процесс платежа состоит из 2-х этапов: вызова платежного окна Robokassa с заданными параметрами и затем, если требуется, осуществления дополнительного запроса к сервису Robokassa для необходимого действия - отмены или подтверждения отложенного платежя или проведения повторной оплаты.
Вызов платежного окна
Чтобы настроить платежное окно для проведения платежа, требуется:
Создать объект PaymentParams, который включает в себя:
данные о заказе OrderParams
данные о покупателе CustomerParams
данные о внешнем виде страницы оплаты ViewParams
    val paymentParams =
    PaymentParams().setParams {
        orderParams {                           // данные заказа
            invoiceId = 12345                   // номер заказа в системе продавца
            orderSum = 200.50                   // сумма заказа
            isRecurrent = false                 // флаг определяющий является ли платеж повторяющимся
            isHold = false                      // флаг определяющий является ли платеж отложенным
            description = "Оплата по заказу"    // описание, показываемое покупателю в платежном окне
            receipt = Receipt                   // объект фискального чека
        }
        customerParams {                        // данные покупателя
            culture = Culture.RU                // язык интерфейса
            email = "john@doe.com"              // электронная почта покупателя для отправки уведомлений об оплате
        }
        viewParams {
            toolbarText = "Рекуррентный платеж" // заголовок окна оплаты
        }
    }.also {
        it.setCredentials(MERCHANT_LOGIN, PASSWORD_1, PASSWORD_2)
    }
Зарегистрировать контракт RobokassaPayLauncher.Contract, и вызвать ActivityResultLauncher.launch
    val payProcessLauncher = registerForActivityResult(RobokassaPayLauncher.Contract) {
        when(it) {
            is RobokassaPayLauncher.Canceled -> {
                // платеж прерван пользователем
            }
            is RobokassaPayLauncher.Error -> {
                // во время проведения платежа произошла ошибка
            }
            is RobokassaPayLauncher.Success -> {
                // платеж выполнен успешно
            }
        }
    }
    payProcessLauncher.launch(RobokassaPayLauncher.StartPay(paymentParams))
Результат платежа вернется в ActivityResultCallback:
при успешно завершенном платеже возвращается RobokassaPayLauncher.Success, который содержит в себе:
invoiceId - номер оплаченного заказа
opKey - идентификатор операции (нужен для оплаты по сохраненной карте)
resultCode CheckRequestCode - код результата выполнения запроса в платежном окне
stateCode CheckPayStateCode - код состояния платежа
при отмене платежа возвращается RobokassaPayLauncher.Canceled
при неуспешном платеже в ответ приходит RobokassaPayLauncher.Error, внутри которого находятся:
error - Throwable
resultCode CheckRequestCode - код результата выполнения запроса в платежном окне
stateCode CheckPayStateCode - код состояния платежа
desc - текстовое описание ошибки
Дополнительные запросы
Если в платежном окне был вызван не обычный платеж, а холдирование средств или рекуррентный платеж, то далее потребуется вызвать дополнительный метод SDK.
При выполнении отложенного платежа (холдировании) необходимо вызвать либо отмену, либо подтверждение платежа
    // Подтверждение отложенного платежа, в качестве paymentParams рекомендуется использовать объект, созданный на этапе вызова платежного окна
    val pa = PaymentAction.init()
    pa.confirmHold(paymentParams)
    lifecycleScope.launch {
        pa.state.collect { ps ->
            if (ps is PayActionState) {
                if (ps.success) {
                    // платеж успешно подтвержден
                } else {
                    // операция завершена с ошибкой
                }
            }
        }
    }

    // Отмена отложенного платежа, в качестве paymentParams рекомендуется использовать объект, созданный на этапе вызова платежного окна
    val pa = PaymentAction.init()
    pa.cancelHold(paymentParams)
    lifecycleScope.launch {
        pa.state.collect { ps ->
            if (ps is PayActionState) {
                if (ps.success) {
                    // платеж успешно отменен
                } else {
                    // операция завершена с ошибкой
                }
            }
        }
    }
При выполнении рекуррентного платежа можно вызвать повторный платеж с прежними параметрами
    // Совершение повторного платежа
    val paymentParams =
    PaymentParams().setParams {
        orderParams {                           // данные заказа
            invoiceId = 12345                   // номер заказа в системе продавца
            previousInvoiceId = 55              // номер первичного заказа, созданного с флагом isRecurrent = true
            orderSum = 200.50                   // сумма заказа
        }
    }.also {
        it.setCredentials(MERCHANT_LOGIN, PASSWORD_1, PASSWORD_2)
    }
    val pa = PaymentAction.init()
    pa.payRecurrent(paymentParams)
    lifecycleScope.launch {
        pa.state.collect { ps ->
            if (ps is PayRecurrentState) {
                if (ps.success) {
                    // повторный платеж успешно инициирован на стороне Robokassa
                } else {
                    // операция завершена с ошибкой
                }
            }
        }
    }
При выполнении повторного платежа по ранее сохраненной карте необходимо заново вызвать платежное окно Robokassa, указав код предыдущей операции с этой картой
    // Совершение повторного платежа
    val paymentParams =
    PaymentParams().setParams {
        orderParams {                           // данные заказа
            invoiceId = 12345                   // номер заказа в системе продавца
            orderSum = 200.50                   // сумма заказа
            token = opKey                       // идентификатор предыдущей операции с картой
            description = "Оплата по заказу"    // описание, показываемое покупателю в платежном окне
            receipt = Receipt                   // объект фискального чека
        }
        customerParams {                        // данные покупателя
            culture = Culture.RU                // язык интерфейса
            email = "john@doe.com"              // электронная почта покупателя для отправки уведомлений об оплате
        }
        viewParams {
            toolbarText = "Оплата сохраненной картой" // заголовок окна оплаты
        }
    }.also {
        it.setCredentials(MERCHANT_LOGIN, PASSWORD_1, PASSWORD_2)
    }
    payProcessLauncher.launch(RobokassaPayLauncher.StartPay(paymentParams))

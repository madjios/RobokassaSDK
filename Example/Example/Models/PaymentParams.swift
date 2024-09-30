import Foundation
import CryptoKit

struct PaymentParams: BaseParams, Codable {
    var merchantLogin: String = ""
    var password1: String = ""
    var password2: String = ""
    
    // Order information
    var order: OrderParams

    // Customer information
    var customer: CustomerParams

    // View parameters for payment page appearance
    var view: ViewParams
}

extension PaymentParams {
    func payPostBody(isTest: Bool) -> [String: Any] {
        var body: [String: Any] = [
            "MerchantLogin": merchantLogin
        ]
        
        var signature = merchantLogin
        
        // Description
        if let description = order.description, !description.isEmpty {
            body["Description"] = description
        }
        
        // Order Sum
        if order.orderSum > 0.0 {
            body["OutSum"] = order.orderSum
            signature += ":\(order.orderSum)"
        }
        
        // Invoice ID
        if self.order.invoiceId > 0 {
            body["invoiceID"] = order.invoiceId
            signature += ":\(order.invoiceId)"
        } else {
            signature += ":"
        }
        
        // Receipt
        if let receipt = order.receipt {
            body["Receipt"] = receipt.toBody()
            
            if let jsonData = try? JSONEncoder().encode(receipt),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                signature += ":\(jsonString)"
            }
        }
        
        // Hold
        if order.isHold {
            body["StepByStep"] = "true"
            signature += ":true"
        }
        
        // Recurrent
        if order.isRecurrent {
            body["Recurring"] = "true"
        }
        
        // Expiration Date
        if let expirationDate = order.expirationDate {
            body["ExpirationDate"] = expirationDate.isoString
        }
        
        // Currency Label
        if let incCurrLabel = order.incCurrLabel, !incCurrLabel.isEmpty {
            body["IncCurrLabel"] = incCurrLabel
        }
        
        // Culture
        if let culture = customer.culture {
            body["Culture"] = culture.iso
        }
        
        // Email
        if let email = customer.email, !email.isEmpty {
            body["Email"] = email
        }
        
        // User IP
        if let ip = customer.ip, !ip.isEmpty {
            body["UserIp"] = ip
            signature += ":\(ip)"
        }
        
        // Test Mode
        if isTest {
            body["IsTest"] = "1"
        }
        
        signature += ":\(password1)"
        
        let signatureValue = md5Hash(signature)
        body["SignatureValue"] = signatureValue
        
        return body
    }
    
    func payPostParams(isTest: Bool) -> String {
        var result = ""
        var signature = ""
        
        result += "MerchantLogin=\(merchantLogin)"
        signature += merchantLogin
        
        // Description
        if let description = self.order.description, !description.isEmpty {
            result += "&Description=\(description)"
        }
        
        // Order Sum
        if self.order.orderSum > 0.0 {
            let outSum = String(order.orderSum)
            result += "&OutSum=\(outSum)"
            signature += ":\(outSum)"
        }
        
        // Invoice ID
        if self.order.invoiceId > 0 {
            let id = String(order.invoiceId)
            result += "&invoiceID=\(id)"
            signature += ":\(id)"
        } else {
            signature += ":"
        }
        
        // Receipt
        if let receipt = order.receipt {
            if let jsonData = try? JSONEncoder().encode(receipt),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                if let jsonEncoded = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    result += "&Receipt=\(jsonEncoded)"
                    signature += ":\(jsonString)"
                }
            }
        }
        
        // Hold
        if order.isHold {
            result += "&StepByStep=true"
            signature += ":true"
        }
        
        // Recurrent
        if order.isRecurrent {
            result += "&Recurring=true"
        }
        
        // Expiration Date
        if let expirationDate = order.expirationDate {
            result += "&ExpirationDate=\(expirationDate.isoString)"
        }
        
        // Currency Label
        if let incCurrLabel = order.incCurrLabel, !incCurrLabel.isEmpty {
            result += "&IncCurrLabel=\(incCurrLabel)"
        }
        
        // Culture
        if let culture = customer.culture {
            result += "&Culture=\(culture.iso)"
        }
        
        // Email
        if let email = customer.email, !email.isEmpty {
            result += "&Email=\(email)"
        }
        
        // User IP
        if let ip = customer.ip, !ip.isEmpty {
            result += "&UserIp=\(ip)"
            signature += ":\(ip)"
        }
        
        // Test Mode
        if isTest {
            result += "&IsTest=1"
        }
        
        signature += ":\(password1)"
        
        let signatureValue = md5Hash(signature)
        result += "&SignatureValue=\(signatureValue)"
        
        return result
    }
    
    // Helper function to generate MD5 hash
    private func md5Hash(_ string: String) -> String {
        // Convert the string to data
        let data = Data(string.utf8)
        
        // Create MD5 hash
        let digest = Insecure.MD5.hash(data: data)
        
        // Convert the hash to a hex string
        return digest.map { String(format: "%02x", $0) }.joined()

    }
}

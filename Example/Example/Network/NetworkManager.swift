import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum Endpoint {
    case getInvoice(PaymentParams, Bool)
    case confirmHoldPayment(PaymentParams, Bool)
    case cancelHoldPayment(PaymentParams, Bool)
    case reccurentPayment(PaymentParams, Bool)
    case checkPaymentStatus(PaymentParams)
    
    var url: String {
        return switch self {
        case .getInvoice: Constants.URLs.main
        case .confirmHoldPayment: Constants.URLs.holdingConfirm
        case .cancelHoldPayment: Constants.URLs.holdingCancel
        case .reccurentPayment: Constants.URLs.recurringPayment
        case .checkPaymentStatus: Constants.URLs.checkPayment
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkPaymentStatus:
            return .get
        default:
            return .post
        }
    }
    
    var body: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    var stringBody: String? {
        switch self {
        case let .getInvoice(params, isTest):
            return params.payPostParams(isTest: isTest)
        case let .confirmHoldPayment(params, isTest):
            return params.payPostParams(isTest: isTest)
        case let .cancelHoldPayment(params, isTest):
            return params.payPostParams(isTest: isTest)
        case let .reccurentPayment(params, isTest):
            return params.payPostParams(isTest: isTest)
        case let .checkPaymentStatus(params):
            return params.checkPaymentParams()
        }
    }
}

enum RequestError: Error {
    case invalidURL
    case networkError(Error)
    case jsonSerializationError(Error)
    case noData
    case invalidResponse
}

class RequestManager {
    private let decoder: JSONDecoder
    
    static let shared = RequestManager()

    private init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
    }
    
    func request<T: Decodable>(to endpoint: Endpoint, type: T.Type) async throws -> T {
        do {
            let data = try await requestTo(endpoint: endpoint)
            let decodedData = try mapToObject(from: data, type: T.self)
            
            return decodedData
        } catch {
            throw error
        }
    }

    private func requestTo(endpoint: Endpoint) async throws -> Data {
        guard let url = URL(string: endpoint.url) else {
            throw RequestError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let body = endpoint.body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw RequestError.jsonSerializationError(error)
            }
        }
        
        if let stringBody = endpoint.stringBody {
            let httpBody = stringBody.data(using: .utf8)
            request.httpBody = httpBody
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw RequestError.invalidResponse
        }

        return data
    }
    
    private func mapToObject<T>(from data: Data, type: T.Type) throws -> T where T : Decodable {
        do {
            return try decoder.decode(type, from: data)
        } catch DecodingError.dataCorrupted(let context) {
            print(context.debugDescription)
            throw MessagedError(message: "Mapping error! Reason: \(context.debugDescription)")
        } catch let DecodingError.keyNotFound(key, context) {
            let message = "\(key.stringValue) was not found, \(context.debugDescription)"
            print(message)
            throw MessagedError(message: "Mapping error! Reason: \(message)")
        } catch let DecodingError.typeMismatch(type, context) {
            let message = "\(type) was expected, \(context.debugDescription) | \(context.codingPath)"
            print(message)
            throw MessagedError(message: "Mapping error! Reason: \(message)")
        } catch let DecodingError.valueNotFound(type, context) {
            let message = "no value was found for \(type), \(context.debugDescription)"
            print(message)
            throw MessagedError(message: "Mapping error! Reason: \(message)")
        } catch {
            print("Unknown error")
            throw MessagedError(message: "Mapping error! Reason: UNKNOWN ERROR")
        }
    }
}

public struct MessagedError: Error {
    let message: String
    var localizedDescription: String? { message }
}

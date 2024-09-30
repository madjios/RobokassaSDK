import Foundation

struct Invoce: Decodable {
    let invoiceID: String
    let errorCode: Int
    let errorMessage: String?
}

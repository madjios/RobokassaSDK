import Foundation

struct OperationStateResponse: Decodable {
    let result: String
    let code: PaymentResult
    let description: String
    let operationState: String
    
    enum CodingKeys: String, CodingKey {
        case result = "Result"
        case code = "Code"
        case description = "Description"
        case operationState = "OperationStateResponse"
    }
}

//struct OperationStateResult: Decodable {
//    let code: PaymentResult
//    let description: String
//    
//    enum CodingKeys: String, CodingKey {
//        case code = "Code"
//        case description = "Description"
//    }
//}

import XCTest
@testable import RobokassaSDK

final class RobokassaSDKTests: XCTestCase {
    func testExample() throws {
        let login = "123"
        let password = "123"
        let text = "LOGIN: \(login)\nPASSWORD: \(password)"
        XCTAssertEqual(Robokassa.start(login: login, password: password), text)
    }
}

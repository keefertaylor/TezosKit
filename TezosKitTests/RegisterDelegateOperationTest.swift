import XCTest
import TezosKit

class RegisterDelegateOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let source = "tz1abc"

    let operation = RegisterDelegateOperation(delegate: source)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"], source)

    XCTAssertNotNil(dictionary["delegate"])
    XCTAssertEqual(dictionary["delegate"], source)
  }
}

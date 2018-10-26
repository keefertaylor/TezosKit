import XCTest
import TezosKit

class DelegationOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let source = "tz1abc"
    let delegate = "tz1def"

    let operation = DelegationOperation(source: source, to: delegate)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"], source)

    XCTAssertNotNil(dictionary["delegate"])
    XCTAssertEqual(dictionary["delegate"], delegate)
  }
}

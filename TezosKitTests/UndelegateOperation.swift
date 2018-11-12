import XCTest
import TezosKit

class UndelegateOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let source = "tz1abc"

    let operation = UndelegateOperation(source: source)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"], source)

    XCTAssertNil(dictionary["delegate"])
  }
}

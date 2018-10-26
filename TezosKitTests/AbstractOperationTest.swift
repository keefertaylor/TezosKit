import XCTest
import TezosKit

class AbstractOperationTest: XCTestCase {
  public func testRequiresReveal() {
    let abstractOperationRequiringReveal = AbstractOperation(source: "tz1abc", kind: .delegation)
    XCTAssertTrue(abstractOperationRequiringReveal.requiresReveal)

    let abstractOperationNotRequiringReveal = AbstractOperation(source: "tz1abc", kind: .reveal)
    XCTAssertFalse(abstractOperationNotRequiringReveal.requiresReveal)
  }

  public func testDictionaryRepresentation() {
    let source = "tz1abc"
    let kind: OperationKind = .delegation
    let fee = TezosBalance(balance: 1)
    let gasLimit = TezosBalance(balance: 2)
    let storageLimit = TezosBalance(balance: 3)

    let abstractOperation = AbstractOperation(source: source, kind: kind, fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
    let dictionary = abstractOperation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"], source)

    XCTAssertNotNil(dictionary["kind"])
    XCTAssertEqual(dictionary["kind"], kind.rawValue)

    XCTAssertNotNil(dictionary["fee"])
    XCTAssertEqual(dictionary["fee"], fee.rpcRepresentation)

    XCTAssertNotNil(dictionary["gas_limit"])
    XCTAssertEqual(dictionary["gas_limit"], gasLimit.rpcRepresentation)

    XCTAssertNotNil(dictionary["storage_limit"])
    XCTAssertEqual(dictionary["storage_limit"], storageLimit.rpcRepresentation)
  }
}

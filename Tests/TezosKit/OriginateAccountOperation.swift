// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class OriginateAccountOperationTest: XCTestCase {
  public func testDictionaryRepresentation() {
    let address = "tz1abc123"
    let operation = OriginateAccountOperation(address: address)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["manager_pub_key"])
    XCTAssertEqual(dictionary["manager_pub_key"] as? String, address)

    XCTAssertNotNil(dictionary["balance"])
    XCTAssertEqual(dictionary["balance"] as? String, "0")
  }

  public func testDictionaryRepresentationFromWallet() {
    guard let wallet = Wallet() else {
      XCTFail()
      return
    }

    let operation = OriginateAccountOperation(wallet: wallet)
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["manager_pub_key"])
    XCTAssertEqual(dictionary["manager_pub_key"] as? String, wallet.address)

    XCTAssertNotNil(dictionary["balance"])
    XCTAssertEqual(dictionary["balance"] as? String, "0")
  }
}
